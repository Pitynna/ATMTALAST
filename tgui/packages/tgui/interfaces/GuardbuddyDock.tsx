import { Button, LabeledList, NoticeBox, ProgressBar, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface DockData {
  powered: boolean;
  authorized: boolean;
  assigned: boolean;
  docked: boolean;
  connected: boolean;
  blocked: boolean;
  name: string | null;
  program: string | null;
  charge: number | null;
  cell: boolean;
  tool: string | null;
  zone: string | null;
  mode: string | null;
  reason: string | null;
}

const programs = [
  { key: 'standby', name: 'Standby' },
  { key: 'patrol', name: 'Patrol' },
];

export const GuardbuddyDock = () => {
  const { act, data } = useBackend<DockData>();
  const {
    powered, authorized, assigned, docked, connected, blocked,
    name, program, charge, cell, tool, zone, mode, reason,
  } = data;
  const canControl = powered && authorized;
  const canDispatch = canControl && docked && !blocked;

  return (
    <Window width={460} height={340}>
      <Window.Content scrollable>
        {!powered && <NoticeBox danger>Dock power unavailable.</NoticeBox>}
        {!authorized && <NoticeBox>Robotics access required for controls.</NoticeBox>}
        <Section
          title={assigned ? name : 'Charging pad'}
          buttons={
            assigned ? (
              <Button
                icon="reply"
                disabled={!canControl || !(connected || docked)}
                onClick={() => act('recall')}
              >
                Recall
              </Button>
            ) : (
              <Button
                icon="link"
                disabled={!canControl || !blocked}
                onClick={() => act('pair')}
              >
                Pair
              </Button>
            )
          }
        >
          {!assigned ? (
            <NoticeBox>Pull one unpaired Guardbuddy onto the pad.</NoticeBox>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Status">
                {mode ?? 'Signal lost'}
              </LabeledList.Item>
              {zone && <LabeledList.Item label="Location">{zone}</LabeledList.Item>}
              {charge !== null && (
                <LabeledList.Item label="Battery">
                  {cell ? (
                    <ProgressBar value={charge} minValue={0} maxValue={100}>
                      {charge}%
                    </ProgressBar>
                  ) : 'No cell'}
                </LabeledList.Item>
              )}
              {program && (
                <LabeledList.Item label="Module">{tool ?? 'Empty'}</LabeledList.Item>
              )}
              {reason && <LabeledList.Item label="Last stop">{reason}</LabeledList.Item>}
            </LabeledList>
          )}
        </Section>
        {assigned && (
          <Section title="Assignment">
            {programs.map(({ key, name }) => (
              <Button
                key={key}
                selected={program === key}
                disabled={!canDispatch}
                onClick={() => act('program', { program: key })}
              >
                {name}
              </Button>
            ))}
            <Button
              icon="play"
              disabled={!canDispatch || !cell || (charge ?? 0) <= 20}
              onClick={() => act('dispatch')}
            >
              Dispatch
            </Button>
            <Button icon="unlink" disabled={!canDispatch} onClick={() => act('unpair')}>
              Unpair
            </Button>
            {blocked && <NoticeBox>The charging pad is occupied.</NoticeBox>}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
