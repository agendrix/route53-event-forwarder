import { Handler } from "aws-lambda";
import AWS from "aws-sdk";

const handler: Handler = async (event) => {
  const eventBridge = new AWS.EventBridge(({region: process.env.REGION}));
  const params = { Entries: [ formatEvent(event) ]};
  try {
    const response = await eventBridge.putEvents(params).promise();
    console.log(`Event ${event.id} successfully forwarded to region ${process.env.REGION}. New event id: ${response.Entries?.shift()?.EventId}`);
  } catch (e) {
    console.log(e);
  }
};

const formatEvent = (event) => {
  const recordName = event.detail?.requestParameters?.changeBatch?.changes[0]?.resourceRecordSet?.name;
  if (recordName) event.detail.requestParameters.recordName = recordName;

  return ({
    Source: process.env['EVENT_SOURCE'],
    Time: event.time,
    Resources: event.resources,
    DetailType: event['detail-type'],
    Detail: JSON.stringify(event.detail)
  })
}

exports.handler = handler;

export const __test__ = {
  handler,
  formatEvent
};
