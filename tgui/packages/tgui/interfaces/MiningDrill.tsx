import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type BufferEntry = {
  name: string;
  amount: number;
};

type MiningDrillData = {
  tier: number;
  status: string;
  on: boolean;
  has_deposit: boolean;
  deposit_name: string | null;
  deposit_amount: number | null;
  deposit_initial: number | null;
  has_cell: boolean;
  cell_charge: number;
  cell_max: number;
  charge_per_minute: number;
  dig_time: number;
  buffer_total: number;
  buffer_capacity: number;
  buffer: BufferEntry[];
  panel_open: boolean;
  module: string | null;
  module_data: ModuleData | null;
};

type ModuleData = {
  kind: string;
  direction?: string;
  blocked?: boolean;
  channel?: string | null;
  connected?: boolean;
};

const ChannelSetter = (props: { current: string | null | undefined }) => {
  const { act } = useBackend();
  const [channel, setChannel] = useState('');
  return (
    <>
      <Input
        placeholder={props.current || 'Channel name'}
        value={channel}
        onChange={setChannel}
      />
      <Button
        icon="satellite-dish"
        disabled={!channel.trim()}
        onClick={() => {
          act('set_channel', { channel });
          setChannel('');
        }}
      >
        Tune
      </Button>
    </>
  );
};

const DIRECTIONS = ['north', 'south', 'east', 'west'];

const DIRECTION_ICONS: Record<string, string> = {
  north: 'arrow-up',
  south: 'arrow-down',
  east: 'arrow-right',
  west: 'arrow-left',
};

const STATUS_COLORS: Record<string, string> = {
  Active: 'good',
  Off: 'label',
  'No power': 'bad',
  'Buffer full': 'average',
  'No ore deposit': 'bad',
  'Deposit depleted': 'average',
  'No receiver': 'average',
};

const formatMinutes = (minutes: number) => {
  if (minutes >= 60) {
    const hours = Math.floor(minutes / 60);
    return `${hours} h ${Math.floor(minutes % 60)} min`;
  }
  return `${Math.floor(minutes)} min`;
};

export const MiningDrill = (_props: unknown) => {
  const { act, data } = useBackend<MiningDrillData>();
  const {
    tier,
    status,
    on,
    has_deposit,
    deposit_name,
    deposit_amount,
    deposit_initial,
    has_cell,
    cell_charge,
    cell_max,
    charge_per_minute,
    dig_time,
    buffer_total,
    buffer_capacity,
    buffer,
    panel_open,
    module,
    module_data,
  } = data;
  return (
    <Window width={420} height={470}>
      <Window.Content scrollable>
        <Section
          title={`Tier ${tier} drill`}
          buttons={
            <>
              <Button
                icon="power-off"
                selected={on}
                disabled={!has_deposit}
                onClick={() => act('toggle')}
              >
                {on ? 'On' : 'Off'}
              </Button>
              <Button icon="box" onClick={() => act('pack')}>
                Pack up
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">
              <Box color={STATUS_COLORS[status] || 'label'} bold>
                {status}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Speed">
              1 ore every {dig_time} seconds
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Ore deposit">
          {has_deposit ? (
            <LabeledList>
              <LabeledList.Item label="Deposit">{deposit_name}</LabeledList.Item>
              <LabeledList.Item label="Remaining">
                <ProgressBar
                  value={deposit_amount || 0}
                  maxValue={deposit_initial || 1}
                >
                  {deposit_amount} / {deposit_initial} ore
                </ProgressBar>
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <NoticeBox>
              {status === 'Deposit depleted'
                ? 'The deposit is exhausted. Pack the drill up and move it.'
                : 'The drill is not standing on an exposed ore deposit.'}
            </NoticeBox>
          )}
        </Section>
        <Section title="Power">
          {has_cell ? (
            <LabeledList>
              <LabeledList.Item label="Cell charge">
                <ProgressBar
                  value={cell_charge}
                  maxValue={cell_max}
                  ranges={{
                    good: [cell_max * 0.5, Infinity],
                    average: [cell_max * 0.15, cell_max * 0.5],
                    bad: [-Infinity, cell_max * 0.15],
                  }}
                >
                  {cell_charge} / {cell_max}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Running time">
                {formatMinutes(cell_charge / charge_per_minute)} at{' '}
                {charge_per_minute} charge per minute
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <NoticeBox>
              No power cell. Open the panel with a screwdriver to insert one.
            </NoticeBox>
          )}
        </Section>
        <Section
          title="Ore buffer"
          buttons={
            <Button
              icon="eject"
              disabled={!buffer_total}
              onClick={() => act('dump')}
            >
              Unload
            </Button>
          }
        >
          <ProgressBar
            value={buffer_total}
            maxValue={buffer_capacity}
            ranges={{
              average: [buffer_capacity, Infinity],
            }}
          >
            {buffer_total} / {buffer_capacity}
          </ProgressBar>
          {buffer.length > 0 && (
            <LabeledList>
              {buffer.map((entry) => (
                <LabeledList.Item key={entry.name} label={entry.name}>
                  {entry.amount}
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
        <Section title="Module">
          <LabeledList>
            <LabeledList.Item
              label="Installed"
              buttons={
                panel_open &&
                !!module && (
                  <Button icon="eject" onClick={() => act('remove_module')}>
                    Remove
                  </Button>
                )
              }
            >
              {module || 'None'}
            </LabeledList.Item>
            {module_data?.kind === 'transmitter' && (
              <>
                <LabeledList.Item label="Channel">
                  <Box mb={0.5}>{module_data.channel || 'Not set'}</Box>
                  <ChannelSetter current={module_data.channel} />
                </LabeledList.Item>
                <LabeledList.Item label="Receiver">
                  <Box color={module_data.connected ? 'good' : 'average'}>
                    {module_data.connected ? 'Connected' : 'No receiver'}
                  </Box>
                </LabeledList.Item>
              </>
            )}
            {module_data?.kind === 'ejector' && (
              <LabeledList.Item label="Output side">
                {DIRECTIONS.map((direction) => (
                  <Button
                    key={direction}
                    icon={DIRECTION_ICONS[direction]}
                    selected={module_data.direction === direction}
                    tooltip={`Eject ore to the ${direction}`}
                    onClick={() => act('set_direction', { direction })}
                  />
                ))}
                {!!module_data.blocked && (
                  <Box inline color="average" ml={1}>
                    Blocked, ore stays in the buffer
                  </Box>
                )}
              </LabeledList.Item>
            )}
            <LabeledList.Item
              label="Service panel"
              buttons={
                panel_open &&
                has_cell && (
                  <Button icon="battery-empty" onClick={() => act('eject_cell')}>
                    Remove cell
                  </Button>
                )
              }
            >
              {panel_open ? 'Open' : 'Closed'}
            </LabeledList.Item>
          </LabeledList>
          {!module && (
            <Box color="label" mt={1}>
              Without a module, ore stays in the buffer until unloaded by hand.
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
