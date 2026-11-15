import {
  Box,
  Button,
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
            <LabeledList.Item label="Installed">
              {module || 'None'}
            </LabeledList.Item>
            <LabeledList.Item label="Service panel">
              {panel_open ? 'Open' : 'Closed'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
