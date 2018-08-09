/***
 * Node External Editor
 *
 * Kevin Gravier <kevin@mrkmg.com>
 * MIT 2018
 */

import {detect} from "chardet";
import {spawn, spawnSync} from "child_process";
import {readFileSync, unlinkSync, writeFileSync} from "fs";
import {decode} from "iconv-lite";
import {tmpNameSync} from "tmp";
import {CreateFileError} from "./errors/CreateFileError";
import {LaunchEditorError} from "./errors/LaunchEditorError";
import {ReadFileError} from "./errors/ReadFileError";
import {RemoveFileError} from "./errors/RemoveFileError";

export interface IEditorParams {
    args: string[];
    bin: string;
}

export type StringCallback = (err: Error, result: string) => void;
export type VoidCallback = () => void;
export {CreateFileError, LaunchEditorError, ReadFileError, RemoveFileError};

export function edit(text: string = "") {
    const editor = new ExternalEditor(text);
    editor.run();
    editor.cleanup();
    return editor.text;
}

export function editAsync(text: string = "", callback: StringCallback) {
    const editor = new ExternalEditor(text);
    editor.runAsync((err: Error, result: string) => {
        if (err) {
            setImmediate(callback, err, null);
        } else {
            try {
                editor.cleanup();
                setImmediate(callback, null, result);
            } catch (cleanupError) {
                setImmediate(callback, cleanupError, null);
            }
        }
    });

}

export class ExternalEditor {
    private static splitStringBySpace(str: string) {
        const pieces: string[] = [];

        let currentString = "";
        for (let strIndex = 0; strIndex < str.length; strIndex++) {
            const currentLetter = str[strIndex];

            if (strIndex > 0 && currentLetter === " " && str[strIndex - 1] !== "\\" && currentString.length > 0) {
                pieces.push(currentString);
                currentString = "";
            } else {
                currentString += currentLetter;
            }
        }

        if (currentString.length > 0) {
            pieces.push(currentString);
        }

        return pieces;
    }

    public text: string = "";
    public tempFile: string;
    public editor: IEditorParams;
    public lastExitStatus: number;

    public get temp_file() {
        console.log("DEPRECATED: temp_file. Use tempFile moving forward.");
        return this.tempFile;
    }

    public get last_exit_status() {
        console.log("DEPRECATED: last_exit_status. Use lastExitStatus moving forward.");
        return this.lastExitStatus;
    }

    constructor(text: string = "") {
        this.text = text;
        this.determineEditor();
        this.createTemporaryFile();
    }

    public run() {
        this.launchEditor();
        this.readTemporaryFile();
        return this.text;
    }

    public runAsync(callback: StringCallback) {
        try {
            this.launchEditorAsync(() => {
                try {
                    this.readTemporaryFile();
                    setImmediate(callback, null, this.text);
                } catch (readError) {
                    setImmediate(callback, readError, null);
                }
            });
        } catch (launchError) {
            setImmediate(callback, launchError, null);
        }
    }

    public cleanup() {
        this.removeTemporaryFile();
    }

    private determineEditor() {
        const editor =
            process.env.VISUAL ? process.env.VISUAL :
            process.env.EDITOR ? process.env.EDITOR :
            /^win/.test(process.platform) ? "notepad" :
            "vim";

        const editorOpts = ExternalEditor.splitStringBySpace(editor).map((piece: string) => piece.replace("\\ ", " "));
        const bin = editorOpts.shift();

        this.editor = {args: editorOpts, bin};
    }

    private createTemporaryFile() {
        try {
            this.tempFile = tmpNameSync({});
            writeFileSync(this.tempFile, this.text, {encoding: "utf8"});
        } catch (createFileError) {
            throw new CreateFileError(createFileError);
        }
    }

    private readTemporaryFile() {
        try {
            const tempFileBuffer = readFileSync(this.tempFile);
            if (tempFileBuffer.length === 0) {
                this.text = "";
            } else {
                const encoding = detect(tempFileBuffer).toString();
                this.text = decode(tempFileBuffer, encoding);
            }
        } catch (readFileError) {
            throw new ReadFileError(readFileError);
        }

    }

    private removeTemporaryFile() {
        try {
            unlinkSync(this.tempFile);
        } catch (removeFileError) {
            throw new RemoveFileError(removeFileError);
        }
    }

    private launchEditor() {
        try {
            const editorProcess = spawnSync(
                this.editor.bin,
                this.editor.args.concat([this.tempFile]),
                {stdio: "inherit"});
            this.lastExitStatus = editorProcess.status;
        } catch (launchError) {
            throw new LaunchEditorError(launchError);
        }
    }

    private launchEditorAsync(callback: VoidCallback) {
        try {
            const editorProcess = spawn(
                this.editor.bin,
                this.editor.args.concat([this.tempFile]),
                {stdio: "inherit"});
            editorProcess.on("exit", (code: number) => {
                this.lastExitStatus = code;
                setImmediate(callback);
            });
        } catch (launchError) {
            throw new LaunchEditorError(launchError);
        }
    }
}
