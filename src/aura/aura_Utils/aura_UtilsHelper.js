({
    init: function (component) {

        var contextComponent = component.get('v.context');
        var utilsProps = {
            _component: {
                writable: false,
                configurable: false,
                enumerable: false,
                value: contextComponent,
            },
        };

        var utils = Object.create(this.getUtils(), utilsProps);

        var componentProps = {
            writable: false,
            configurable: false,
            enumerable: false,
            value: utils,
        };
        Object.defineProperty(contextComponent, 'utils', componentProps);
    },

    getUtils: function () {
        if (!this._utils) {
            this._utils = this.createUtils();
        }

        return this._utils;
    },

    createUtils: function () {

        return {
            callApex: this.callApex,
            execute: this.execute,
            check: function () {
                console.log('CHECK!!!')
            },
            showToast: this.showToast,
            validateInputs: this.validateInputs,
            validate: this.validate,
            validateComponents: this.validateComponents,
            createComponent: this.createComponent,
            flatten: this.flatten,
            chunk: this.chunk,
            showError: this.showError,
            showErrors: this.showErrors,
            showSuccess: this.showSuccess,
            getURlParams: this.getURlParams,
            callApexPromise : this.callApexPromise,
            executePromise: this.executePromise,
        }
    },


    callApex: function (action, params, success, fail) {

        if (!action) {
            throw 'No Action'
        }

        action.setParams(params);
        action.setBackground();

        action.setCallback(this, function (a) {
            if (a.getState() === "SUCCESS") {
                $A.log("Success", a.getReturnValue())
                if (success) {
                    success.apply(this, [a.getReturnValue()])
                }
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError())
                if (fail) {
                    fail.apply(this, [a.getError()])
                } else {
                    var error = a.getError()
                    console.error('callApex error', error)
                    if (error && error.length) {
                        alert(error[0].message)
                    } else {
                        throw error
                    }
                }
            }
        });

        $A.enqueueAction(action)

    },

    callApexPromise: function (action, params) {
        return new Promise(function (resolve, reject) {
            action.setParams(params);
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let retVal = response.getReturnValue();
                    return resolve(retVal);
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors && errors.length && errors[0] && errors[0].message) {
                        return reject(new Error(errors[0].message));
                    } else {
                        return reject(new Error("Unknown error!"));
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    executePromise: function (cmp, processor, request, showToast) {
        let that = this;

        console.log(processor, 'REQUEST', JSON.parse(JSON.stringify(request)));

        return that.callApexPromise(
            cmp.get('c.execute'),
            {
                processor: processor,
                requestJSON: JSON.stringify(request)
            }
        )
            .then($A.getCallback(responseJSON => {
                let response = JSON.parse(responseJSON);
                if (response.isValid !== true) {
                    console.error(response.errors);
                    if(showToast === undefined || showToast === true) {
                        this.showErrors(cmp, response.errors);
                    }
                    return Promise.reject(response.errors);
                } else {
                    console.log(processor, 'RESPONSE', JSON.parse(JSON.stringify(response)));
                    return Promise.resolve(response);
                }
            }));
    },

    showError: function (component, error) {
        this.showErrors(component, [error]);
    },

    showErrors: function (component, errors) {
        for (var i = 0; i < errors.length; i++) {
            this.showToast({
                "title": "Error",
                "message": errors[i].message,
                "type": "error"
            });
        }
    },

    showSuccess: function (component, message) {
        this.showToast({
            "title": "Success",
            "message": message,
            "type": "success"
        });
    },

    execute: function (cmp, processor, request, success, fail) {

        var that = this;

        return new Promise($A.getCallback(function (resolve, reject) {

            var failFn = function (errors) {
                console.error('execute error', errors);
                if (fail) {
                    fail(errors);
                    reject(errors);
                } else {
                    throw errors;
                }
            };

            console.log(processor, 'REQUEST', JSON.parse(JSON.stringify(request)));

            that.callApex(
                cmp.get('c.execute'),
                {
                    processor: processor,
                    requestJSON: JSON.stringify(request)
                },
                function (responseJSON) {
                    var response = JSON.parse(responseJSON);
                    console.log(processor, 'RESPONSE', JSON.parse(JSON.stringify(response)));
                    if (response.isValid !== true) {
                        failFn.call(that, response.errors);
                        reject(response.errors);
                    } else {
                        if(success !== undefined){
                            success.call(this, response);
                        }
                        resolve(response);
                    }
                },
                failFn
            );

        }));

    },

    showToast: function (params) {
        var toastEvent = $A.get("e.force:showToast");
        params = params || {};
        if (toastEvent) {
            toastEvent.setParams(params);
            toastEvent.fire();
        } else {
            console.log('NO TOAST', params);
            alert(params.title || params.message || 'NO TOAST: ' + JSON.stringify(params));
        }
    },

    validateInputs: function (component, inputIds) {

        var validationResult = {
            errorsByInputs: [],
            allValid: true,
            getErrorMessages: function () {
                var errors = [];
                this.errorsByInputs.forEach(function (errorsByInput) {
                    errors.push(errorsByInput.errors.join(','));
                })

                return errors;
            }
        };

        inputIds.forEach(function (id) {

            var validationErrors = [
                'badInput',
                'customError',
                'patternMismatch',
                'rangeOverflow',
                'rangeUnderflow',
                'stepMismatch',
                'tooLong',
                'tooShort',
                'typeMismatch',
                'valueMissing'
            ];

            var capitalizeFirstLetter = function (string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            }

            var inputCmp = component.find(id);
            if (inputCmp) {
                var validity = inputCmp.get('v.validity');
                if (validity && validity.valid == false) {

                    var errors = [];
                    validationErrors.forEach(function (validationErrorField) {
                        if (validity[validationErrorField] == true) {
                            var errorMessageField = 'v.messageWhen' + capitalizeFirstLetter(validationErrorField);
                            //
                            var errorMessage = inputCmp.get(errorMessageField);
                            if (errorMessage) {
                                errors.push(errorMessage);
                            } else {
                                errors.push('Please check: ' + inputCmp.get('v.label'));
                            }
                        }
                    })

                    validationResult.errorsByInputs.push({
                        id: id,
                        inputCmp: inputCmp,
                        errors: errors
                    });

                    validationResult.allValid = false;

                }
            }
        })

        return validationResult;
    },

    validate: function (containerComponent, options) {

        options = options || {}
        options.additionalComponentTypes = options.additionalComponentTypes || [];

        var componentTypes = [
            'lightning:input',
            'lightning:select',
            'lightning:textarea',
            'lightning:radioGroup',
            'lightning:checkboxGroup',
            'c:aura_Validity',
            'c:aura_Lookup',
            'c:lwcLookup',
            'c:aura_Combobox'
        ];

        var inputComponents = [];

        componentTypes = componentTypes.concat(options.additionalComponentTypes);

        componentTypes.forEach(function (componentType) {
            inputComponents = inputComponents.concat(containerComponent.find({instancesOf: componentType}));
        });

        return this.validateComponents(inputComponents);
    },

    validateComponents: function (components) {

        var validationResult = {
            errorsByInputs: [],
            allValid: true,
            getErrorMessages: function () {
                var errors = [];
                this.errorsByInputs.forEach(function (errorsByInput) {
                    errors.push(errorsByInput.errors.join(','));
                })

                return errors;
            }
        };

        components.forEach(function (inputCmp) {

            var validationErrors = [
                'badInput',
                'customError',
                'patternMismatch',
                'rangeOverflow',
                'rangeUnderflow',
                'stepMismatch',
                'tooLong',
                'tooShort',
                'typeMismatch',
                'valueMissing'
            ];

            var defaultErrorMessages = {
                badInput: 'Enter a valid value.',
                patternMismatch: 'Your entry does not match the allowed pattern.',
                rangeOverflow: 'The number is too high.',
                rangeUnderflow: 'The number is too low.',
                stepMismatch: 'Your entry isn\'t a valid increment.',
                tooLong: 'Your entry is too long.',
                tooShort: 'Your entry is too short.',
                typeMismatch: 'You have entered an invalid format.',
                valueMissing: 'Complete this field.'
            };


            var capitalizeFirstLetter = function (string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            }

            if (inputCmp) {

                var validity;
                if(inputCmp && inputCmp.getType && (inputCmp.getType() == 'c:aura_Lookup' || inputCmp.getType() == 'c:lwcLookup')){
                    // Do no get validity from custom components.
                    validity = undefined;
                } else {
                    try {
                        validity = inputCmp.get('v.validity');
                    } catch (e) {
                    }
                }

                if (validity == undefined) {

                    if (inputCmp.getConcreteComponent) {
                        inputCmp = inputCmp.getConcreteComponent();
                    }

                    var hasShowErrorMethod = inputCmp.showError != undefined || inputCmp.get('c.showError') != undefined;
                    var hasHideErrorMethod = inputCmp.hideError != undefined ||  inputCmp.get('c.hideError') != undefined;
                    var hasValidateMethod = inputCmp.validate !== undefined;
                    if(hasShowErrorMethod == true){

                        var isRequired = inputCmp.get('v.required');
                        var hasError = inputCmp.get('v.error');
                        var errorMessage = inputCmp.get('v.errorMessage');
                        var isEmptyValue = inputCmp.getType() == 'maica_cc:aura_Combobox' ? $A.util.isEmpty(inputCmp.get('v.selectedValue')) : $A.util.isEmpty(inputCmp.get('v.value'));

                        if (isRequired && isEmptyValue){

                            inputCmp.showError('Complete this field.');

                            validationResult.errorsByInputs.push({
                                inputCmp: inputCmp,
                                errors: [
                                    inputCmp.get('v.label') + ': Complete this field.'
                                ]
                            });

                            validationResult.allValid = false;
                        } else if (hasError && errorMessage && errorMessage != 'Complete this field.') {
                            validationResult.errorsByInputs.push({
                                inputCmp: inputCmp,
                                errors: [
                                    inputCmp.get('v.label') + ': ' + errorMessage
                                ]
                            });

                            validationResult.allValid = false;
                        } else if (hasHideErrorMethod == true) {
                            inputCmp.hideError();
                        }
                    }

                    if (inputCmp.validate != null && !inputCmp.validate()) {
                        let errorMessages = (inputCmp.get('v.errorMessages') || []).filter(error => error.message ? error.message !== 'Complete this field.' : error !== 'Complete this field.');
                        if (!errorMessages || errorMessages.length === 0) {
                            errorMessages = [inputCmp.get('v.label') + ': Complete this field.'];
                        }
                        validationResult.errorsByInputs.push({
                            inputCmp: inputCmp,
                            errors: errorMessages
                        });
                        validationResult.allValid = false;
                    }

                } else if (validity && validity.valid == false) {

                    var errors = [];
                    validationErrors.forEach(function (validationErrorField) {
                        if (validity[validationErrorField] == true) {
                            var errorMessageField = 'v.messageWhen' + capitalizeFirstLetter(validationErrorField);
                            var errorMessage = inputCmp.get(errorMessageField);
                            errorMessage = errorMessage || defaultErrorMessages[validationErrorField];
                            if (errorMessage) {
                                errors.push(inputCmp.get('v.label') + ': ' + errorMessage);
                            } else {
                                errors.push(inputCmp.get('v.label') + ': ' + (
                                    ($A.util.isEmpty(inputCmp.get('v.value')) ? inputCmp.get('v.messageWhenValueMissing')  : inputCmp.get('v.messageWhenBadInput')) || inputCmp.get('v.label'))
                                );
                            }
                        }
                    })

                    validationResult.errorsByInputs.push({
                        inputCmp: inputCmp,
                        errors: errors
                    });

                    validationResult.allValid = false;

                    //

                    if (inputCmp.reportValidity != undefined) {
                        inputCmp.reportValidity();
                    } else if (inputCmp.showHelpMessageIfInvalid != undefined) {
                        inputCmp.showHelpMessageIfInvalid();
                    }

                }

            }
        })

        return validationResult;
    },

    createComponent: function (componentName, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            $A.createComponent(
                componentName,
                params,
                function (newCmp, status, errorMessage) {
                    if (status === "SUCCESS") {
                        resolve(newCmp);
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        reject(errorMessage);
                    }
                }
            );
        }));
    },

    flatten: function (data) {
        var result = {};

        function recurse(cur, prop) {
            if (Object(cur) !== cur) {
                result[prop] = cur;
            } else if (Array.isArray(cur)) {
                for (var i = 0, l = cur.length; i < l; i++)
                    recurse(cur[i], prop + "[" + i + "]");
                if (l == 0)
                    result[prop] = [];
            } else {
                var isEmpty = true;
                for (var p in cur) {
                    isEmpty = false;
                    recurse(cur[p], prop ? prop + "." + p : p);
                }
                if (isEmpty && prop)
                    result[prop] = {};
            }
        }

        recurse(data, "");
        return result;
    },

    chunk: function (array, n) {
        if (!array.length) {
            return [];
        }
        return [array.slice(0, n)].concat(this.chunk(array.slice(n), n));
    },

    getURlParams: function () {
        return decodeURI(window.location.search)
            .replace('?', '')
            .split('&')
            .map(function (param) {
                return param.split('=');
            })
            .reduce(function (values, item) {
                var key = item[0];
                var value = item[1];
                values[key ? key.toLowerCase() : key] = value;
                return values
            }, {});
    }

})