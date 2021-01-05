import { readFileSync } from "fs";

export const MOCKED_ROUTE53_EVENT = JSON.parse(readFileSync(`${__dirname}/route53-event.json`).toString());
