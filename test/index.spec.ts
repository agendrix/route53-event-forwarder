import assert from "assert";
import { __test__ } from "../lambda/index";
import { MOCKED_ROUTE53_EVENT } from "./mocks";

describe("formatEvent", () => {
  const fakeEvent: any = MOCKED_ROUTE53_EVENT;

  it("formats Detail attribute as JSON", async () => {
    const formattedEvent = __test__.formatEvent(fakeEvent);
    assert.doesNotThrow(() => JSON.parse(formattedEvent.Detail));
  })

  it("adds recordName to requestParameters object if present", async () => {
    const formattedEvent = __test__.formatEvent(fakeEvent);
    const eventDetail = JSON.parse(formattedEvent.Detail);
    assert.strictEqual(eventDetail.requestParameters.recordName, "service-name.cluster.service.")
  });
});
