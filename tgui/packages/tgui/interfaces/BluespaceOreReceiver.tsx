import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type OreEntry = {
  name: string;
  amount: number;
};

type ReceiverData = {
  channel: string | null;
  ore: OreEntry[];
  total: number;
};

export const BluespaceOreReceiver = (_props: unknown) => {
  const { act, data } = useBackend<ReceiverData>();
  const { channel, ore, total } = data;
  const [newChannel, setNewChannel] = useState('');
  return (
    <Window width={380} height={380}>
      <Window.Content scrollable>
        <Section
          title="Channel"
          buttons={
            !!channel && (
              <Button icon="times" onClick={() => act('clear_channel')}>
                Clear
              </Button>
            )
          }
        >
          <Box mb={1} bold color={channel ? 'good' : 'label'}>
            {channel || 'Not tuned: drills cannot send ore here.'}
          </Box>
          <Input
            placeholder="Channel name"
            value={newChannel}
            onChange={setNewChannel}
          />
          <Button
            icon="satellite-dish"
            disabled={!newChannel.trim()}
            onClick={() => {
              act('set_channel', { channel: newChannel });
              setNewChannel('');
            }}
          >
            Tune
          </Button>
        </Section>
        <Section
          title={`Stored ore: ${total}`}
          buttons={
            <Button icon="eject" disabled={!total} onClick={() => act('unload')}>
              Unload
            </Button>
          }
        >
          {ore.length ? (
            <LabeledList>
              {ore.map((entry) => (
                <LabeledList.Item key={entry.name} label={entry.name}>
                  {entry.amount}
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <NoticeBox>Empty.</NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
