"use strict";
/***
 * Node External Editor
 *
 * Kevin Gravier <kevin@mrkmg.com>
 * MIT 2018
 */
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var CreateFileError = /** @class */ (function (_super) {
    __extends(CreateFileError, _super);
    function CreateFileError(originalError) {
        var _newTarget = this.constructor;
        var _this = _super.call(this, "Failed to create temporary file for editor") || this;
        _this.originalError = originalError;
        var proto = _newTarget.prototype;
        if (Object.setPrototypeOf) {
            Object.setPrototypeOf(_this, proto);
        }
        else {
            _this.__proto__ = _newTarget.prototype;
        }
        return _this;
    }
    return CreateFileError;
}(Error));
exports.CreateFileError = CreateFileError;
