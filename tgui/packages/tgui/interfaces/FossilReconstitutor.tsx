import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Feedback = 'match' | 'shift' | 'foreign' | 'empty' | null;

type Locus = {
  fragment: string | null;
  feedback: Feedback;
};

type Genome = {
  index: number;
  codename: string;
  name: string;
  completed: boolean;
  recovered: number;
  slots: Locus[];
  fidelity: number;
  grade: 'pristine' | 'stable' | 'unstable';
  runs: number;
};

type Fragment = {
  code: string;
  used_by: string[];
};

type Incubator = {
  biomass: number;
  max_biomass: number;
  cost: number;
  growing: string | null;
  progress: number;
  powered: boolean;
};

type Data = {
  kind: 'fauna' | 'flora';
  busy: string | null;
  busy_left: number;
  log: string[];
  authorized: boolean;
  genomes: Genome[];
  pool: Fragment[];
  fossils_processed: number;
  species_total: number;
  genome_length: number;
  exhausted: boolean;
  incubator?: Incubator;
  seed_cooldown?: number;
};

const GRADE_COLOR = {
  pristine: 'good',
  stable: 'average',
  unstable: 'bad',
};

const FEEDBACK_TEXT = {
  match: 'Confirmed at this locus',
  shift: 'Belongs to this genome, but at another locus',
  foreign: 'Does not belong to this genome',
  empty: 'Empty locus',
};

const OVERLAP = 2;

const Bases = (props: { code: string | null }) => {
  const { code } = props;
  if (!code) {
    return <Box color="label">· · ·</Box>;
  }
  return (
    <span className="FossilReconstitutor__bases">
      {code.split('').map((base, i) => (
        <span
          // biome-ignore lint/suspicious/noArrayIndexKey: bases are positional
          key={i}
          className={`FossilReconstitutor__base--${base}`}
        >
          {base}
        </span>
      ))}
    </span>
  );
};

const joined = (left: string | null, right: string | null) =>
  !!left && !!right && left.slice(-OVERLAP) === right.slice(0, OVERLAP);

export const FossilReconstitutor = () => {
  const { data } = useBackend<Data>();
  const [selected, setSelected] = useState<string | null>(null);
  const [hideUsed, setHideUsed] = useState(false);
  const fauna = data.kind === 'fauna';
  return (
    <Window theme="xenoarch" width={900} height={680}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <StatusBar />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <Section
                  fill
                  scrollable
                  title={fauna ? 'Fauna gene sequences' : 'Flora gene sequences'}
                >
                  <Genomes selected={selected} setSelected={setSelected} />
                </Section>
              </Stack.Item>
              <Stack.Item width="250px">
                <Stack fill vertical>
                  <Stack.Item grow basis={0}>
                    <Section
                      fill
                      scrollable
                      title="Fragment pool"
                      buttons={
                        <Button.Checkbox
                          checked={hideUsed}
                          onClick={() => setHideUsed(!hideUsed)}
                          tooltip="Hide fragments already placed in a sequence"
                        >
                          Unused
                        </Button.Checkbox>
                      }
                    >
                      <FragmentPool
                        selected={selected}
                        setSelected={setSelected}
                        hideUsed={hideUsed}
                      />
                    </Section>
                  </Stack.Item>
                  {fauna && (
                    <Stack.Item>
                      <IncubatorPanel />
                    </Stack.Item>
                  )}
                  <Stack.Item height="150px">
                    <Section fill scrollable title="Scanner log">
                      {data.log.length === 0 && (
                        <Box color="label">No samples processed.</Box>
                      )}
                      {data.log.map((line, i) => (
                        <Box
                          // biome-ignore lint/suspicious/noArrayIndexKey: log lines repeat
                          key={i}
                          fontSize="0.9em"
                          color={i === 0 ? 'white' : 'label'}
                        >
                          {line}
                        </Box>
                      ))}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StatusBar = () => {
  const { data } = useBackend<Data>();
  const completed = data.genomes.filter((genome) => genome.completed).length;
  const fauna = data.kind === 'fauna';
  return (
    <Section>
      <Stack align="center">
        <Stack.Item>
          <Icon
            name={fauna ? 'bone' : 'seedling'}
            size={2.2}
            color="label"
            mx={1}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold fontSize="1.2em">
            Garland Corp. Genetic Reconstitutor
          </Box>
          <Box color="label">
            {fauna
              ? 'Insert fossilised bones, skulls or shells.'
              : 'Insert fossilised plants.'}{' '}
            Fossils processed: {data.fossils_processed}. Sequences found:{' '}
            {data.genomes.length}/{data.species_total}, assembled: {completed}.
          </Box>
        </Stack.Item>
        <Stack.Item width="220px">
          {data.busy ? (
            <ProgressBar value={1} color="average">
              <Icon name="cog" spin mr={1} />
              {data.busy} ({data.busy_left}s)
            </ProgressBar>
          ) : (
            <ProgressBar value={1} color="good">
              Idle
            </ProgressBar>
          )}
        </Stack.Item>
      </Stack>
      {!data.authorized && (
        <NoticeBox danger mt={1}>
          Access denied: research or xenoarchaeology clearance required.
        </NoticeBox>
      )}
      {data.exhausted && (
        <NoticeBox info mt={1}>
          Every recoverable fragment has been extracted. Remaining fossils are
          better spent in the destructive analyser.
        </NoticeBox>
      )}
      <Collapsible title="Assembly protocol" mt={1}>
        <Box color="label" fontSize="0.95em">
          Each species has a genome of {data.genome_length} loci. Fossils yield
          fragments of six bases; some are degraded noise. Neighbouring
          fragments overlap: the last two bases of one repeat as the first two
          of the next, and a joined pair shows a green link. Genomes open with{' '}
          <Bases code="ATG" /> and close with <Bases code="TAA" />. Select a
          fragment, then click a locus to place it. A sequencing run marks each
          locus <Box inline color="good">confirmed</Box>,{' '}
          <Box inline color="average">misplaced</Box> or{' '}
          <Box inline color="bad">foreign</Box>. Every failed run degrades the
          sample: pristine genomes give docile animals and vigorous seeds,
          unstable ones give malformed results.
        </Box>
      </Collapsible>
    </Section>
  );
};

type SelectionProps = {
  selected: string | null;
  setSelected: (code: string | null) => void;
};

const Genomes = (props: SelectionProps) => {
  const { data } = useBackend<Data>();
  if (data.genomes.length === 0) {
    return (
      <Stack fill vertical align="center" justify="center">
        <Stack.Item>
          <Icon name="dna" size={5} color="label" />
        </Stack.Item>
        <Stack.Item color="label" mt={2}>
          No gene sequences recovered. Process fossils to begin.
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <>
      {data.genomes.map((genome) => (
        <GenomeCard key={genome.index} genome={genome} {...props} />
      ))}
    </>
  );
};

const GenomeCard = (props: SelectionProps & { genome: Genome }) => {
  const { act, data } = useBackend<Data>();
  const { genome, selected, setSelected } = props;
  const fauna = data.kind === 'fauna';
  const onLocus = (locus: number, slot: Locus) => {
    if (genome.completed || !data.authorized) {
      return;
    }
    if (selected) {
      act('place', { genome: genome.index, locus, fragment: selected });
      setSelected(null);
    } else if (slot.fragment) {
      act('clear_locus', { genome: genome.index, locus });
    }
  };
  return (
    <Section
      title={
        <>
          {genome.completed ? (
            <Box inline color="good">
              <Icon name="check-circle" mr={1} />
              {genome.name}
            </Box>
          ) : (
            genome.codename
          )}
          <Box inline color="label" ml={1} fontSize="0.85em">
            {genome.completed
              ? `(${genome.codename})`
              : `${genome.recovered}/${data.genome_length} fragments recovered`}
          </Box>
        </>
      }
      buttons={
        genome.completed ? (
          fauna ? (
            <Button
              icon="flask"
              disabled={!data.authorized || !data.incubator}
              tooltip={
                data.incubator
                  ? `Grow in the linked tank (${data.incubator.cost} biomass)`
                  : 'No growth tank within three metres'
              }
              onClick={() => act('grow', { genome: genome.index })}
            >
              Grow specimen
            </Button>
          ) : (
            <Button
              icon="seedling"
              disabled={
                !data.authorized || !!data.busy || (data.seed_cooldown ?? 0) > 0
              }
              onClick={() => act('synthesize', { genome: genome.index })}
            >
              {(data.seed_cooldown ?? 0) > 0
                ? `Recharging (${data.seed_cooldown}s)`
                : 'Synthesise seeds'}
            </Button>
          )
        ) : (
          <>
            <Button
              icon="eraser"
              disabled={!data.authorized}
              tooltip="Remove every fragment from this sequence"
              onClick={() => act('clear_all', { genome: genome.index })}
            />
            <Button
              icon="play"
              color="good"
              disabled={!data.authorized || !!data.busy}
              tooltip="Sequencing run: check every locus. A failed run costs fidelity."
              onClick={() => act('verify', { genome: genome.index })}
            >
              Run
            </Button>
          </>
        )
      }
    >
      <Box mb={1} style={{ whiteSpace: 'nowrap', overflowX: 'auto' }}>
        {genome.slots.map((slot, i) => {
          const locus = i + 1;
          const next = genome.slots[i + 1];
          return (
            // biome-ignore lint/suspicious/noArrayIndexKey: loci are positional
            <Box inline key={i}>
              <Tooltip
                content={
                  slot.fragment
                    ? `Locus ${locus}: ${slot.feedback ? FEEDBACK_TEXT[slot.feedback] : 'not yet sequenced'}${genome.completed ? '' : '. Click to remove.'}`
                    : `Locus ${locus}: empty`
                }
              >
                <div
                  className={classes([
                    'FossilReconstitutor__locus',
                    slot.feedback &&
                      slot.feedback !== 'empty' &&
                      `FossilReconstitutor__locus--${slot.feedback}`,
                    selected &&
                      !genome.completed &&
                      'FossilReconstitutor__locus--target',
                  ])}
                  onClick={() => onLocus(locus, slot)}
                >
                  <Box color="label" fontSize="0.75em">
                    {locus}
                  </Box>
                  <Bases code={slot.fragment} />
                </div>
              </Tooltip>
              {i < genome.slots.length - 1 && (
                <span
                  className={classes([
                    'FossilReconstitutor__link',
                    joined(slot.fragment, next?.fragment) &&
                      'FossilReconstitutor__link--joined',
                  ])}
                >
                  <Icon name="link" />
                </span>
              )}
            </Box>
          );
        })}
      </Box>
      <LabeledList>
        <LabeledList.Item
          label="Sample fidelity"
          buttons={
            <Box color={GRADE_COLOR[genome.grade]} bold width="70px">
              {genome.grade.toUpperCase()}
            </Box>
          }
        >
          <ProgressBar
            value={genome.fidelity / 100}
            ranges={{
              good: [0.8, Infinity],
              average: [0.5, 0.8],
              bad: [-Infinity, 0.5],
            }}
          >
            {genome.fidelity}% · {genome.runs} run{genome.runs === 1 ? '' : 's'}
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const FragmentPool = (props: SelectionProps & { hideUsed: boolean }) => {
  const { data } = useBackend<Data>();
  const { selected, setSelected, hideUsed } = props;
  const visible = data.pool.filter(
    (fragment) => !hideUsed || fragment.used_by.length === 0,
  );
  if (visible.length === 0) {
    return <Box color="label">No fragments to show.</Box>;
  }
  return (
    <>
      {selected && (
        <NoticeBox info>
          <Bases code={selected} /> selected: click a locus.
        </NoticeBox>
      )}
      {visible.map((fragment) => (
        <Tooltip
          key={fragment.code}
          content={
            fragment.used_by.length
              ? `Placed in: ${fragment.used_by.join(', ')}`
              : 'Not placed'
          }
        >
          <div
            className={classes([
              'FossilReconstitutor__fragment',
              fragment.used_by.length > 0 &&
                'FossilReconstitutor__fragment--used',
              selected === fragment.code &&
                'FossilReconstitutor__fragment--selected',
            ])}
            onClick={() =>
              setSelected(selected === fragment.code ? null : fragment.code)
            }
          >
            <Bases code={fragment.code} />
          </div>
        </Tooltip>
      ))}
    </>
  );
};

const IncubatorPanel = () => {
  const { data } = useBackend<Data>();
  const tank = data.incubator;
  return (
    <Section title="Growth tank">
      {!tank ? (
        <Box color="bad">
          <Icon name="unlink" mr={1} />
          No tank within three metres.
        </Box>
      ) : (
        <LabeledList>
          <LabeledList.Item label="Power">
            <Box color={tank.powered ? 'good' : 'bad'}>
              {tank.powered ? 'Online' : 'No power'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Biomass">
            <ProgressBar
              value={tank.biomass / tank.max_biomass}
              color={tank.biomass >= tank.cost ? 'good' : 'average'}
            >
              {tank.biomass}/{tank.max_biomass}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Specimen">
            {tank.growing ? (
              <ProgressBar value={tank.progress / 100} color="average">
                {tank.growing}: {tank.progress}%
              </ProgressBar>
            ) : (
              <Box color="label">Empty</Box>
            )}
          </LabeledList.Item>
        </LabeledList>
      )}
    </Section>
  );
};
