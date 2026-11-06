import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type MailData = {
  mode: number;
  pressure: number;
  isAI: boolean;
  panel_open: boolean;
  flushing: boolean;
  busy: boolean;
  connected: boolean;
  address: string;
  destination: number;
  destinations: { id: number; name: string }[];
  item_count: number;
  received: number;
};

export const PneumaticMail = () => {
  const { act, data } = useBackend<MailData>();
  const locked = data.busy || data.panel_open;
  return (
    <Window width={430} height={550}>
      <Window.Content scrollable>
        <Section title="Pneumatic mail">
          <LabeledList>
            <LabeledList.Item label="Receiving address">{data.address}</LabeledList.Item>
            <LabeledList.Item label="Items loaded">{data.item_count}</LabeledList.Item>
            <LabeledList.Item label="Deliveries received">{data.received}</LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <ProgressBar value={data.pressure} minValue={0} maxValue={100} />
            </LabeledList.Item>
          </LabeledList>
          {!data.connected && <NoticeBox danger>No disposal trunk connected.</NoticeBox>}
          <Box mt={1}>Insert items, select a department, then send. The pipe network must be routed to that department.</Box>
          <Stack mt={1}>
            <Stack.Item>
              <Button icon="paper-plane" selected={data.flushing} disabled={locked || data.isAI || !data.connected || !data.destination || !data.item_count || data.mode <= 0} onClick={() => act(data.flushing ? 'disengageHandle' : 'engageHandle')}>
                {data.busy ? 'Sending' : data.flushing ? 'Queued' : 'Send mail'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button icon="eject" disabled={data.busy || data.isAI} onClick={() => act('eject')}>Eject items</Button>
            </Stack.Item>
            <Stack.Item>
              <Button icon="power-off" selected={data.mode > 0} disabled={locked} onClick={() => act(data.mode > 0 ? 'pumpOff' : 'pumpOn')}>Pump</Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Destination">
          <Stack wrap>
            {data.destinations.map((destination) => (
              <Stack.Item key={destination.id}>
                <Button width="180px" selected={data.destination === destination.id} disabled={locked} onClick={() => act('destination', { id: destination.id })}>
                  {destination.name}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
