/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-call */

import { execSync } from "node:child_process";
import { readdirSync } from "fs";
import { task } from "hardhat/config";

const allFiles = (dir: string) => {
    const result: string[] = [];
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
        const entryName: string = dir + "/" + entry.name;
        if (entry.isDirectory()) {
            result.push(...allFiles(entryName));
        } else {
            result.push(entryName);
        }
    }
    return result;
};

task("preprocess", "Run Pre-Processor").setAction(async () => {
    const preFiles: string[] = allFiles("contracts").filter((value: string) => {
        return value.endsWith(".pre");
    });

    for (const fileName of preFiles) {
        let newFileName: string = fileName.slice(0, -4);
        execSync(`yarn solpp -o "${newFileName}" "${fileName}"`);
        execSync(`yarn prettier --write "${newFileName}"`);
    }
});
