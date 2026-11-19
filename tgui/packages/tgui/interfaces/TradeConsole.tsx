import { useState } from 'react';
import {
  Box,
  Button,
  Chart,
  Icon,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Commodity = {
  id: string;
  name: string;
  desc: string;
  category: string;
  unit: string;
  price: number;
  base_price: number;
  in_demand: boolean;
  history: number[];
};

type Market = {
  commodities: Commodity[];
  next_shift: number;
  quest_min: number;
  quest_max: number;
};

type Offer = {
  ref: string;
  name: string;
  selling: boolean;
  price: number;
  stock: number;
  bundle: number;
  haggled: boolean;
  in_demand: boolean;
};

type Trader = {
  id: string;
  name: string;
  title: string;
  desc: string;
  icon: string;
  color: string;
  message: string;
  patience: number;
  contraband: boolean;
  selling: Offer[];
  buying: Offer[];
};

type Data = {
  market: Market;
  traders: Trader[];
  away_count: number;
  pending_orders: number;
  freighter: string;
  status: string | null;
  logged_in: boolean;
  owner?: string;
  balance?: number;
  cargo_access?: boolean;
  payers?: Payer[];
  paying_department?: string | null;
};

type Payer = {
  id: string | null;
  name: string;
  balance: number;
};

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${minutes}:${rest < 10 ? '0' : ''}${rest}`;
};

export const TradeConsole = () => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState(1);
  return (
    <Window width={900} height={640} title="Trade Console">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <AccountBar />
          </Stack.Item>
          {!!data.status && (
            <Stack.Item>
              <NoticeBox info>{data.status}</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={tab === 0} onClick={() => setTab(0)}>
                Market
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                Traders ({data.traders.length})
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 0 && <MarketTab />}
            {tab === 1 && <TradersTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AccountBar = () => {
  const { act, data } = useBackend<Data>();
  if (!data.logged_in) {
    return (
      <Section>
        <Stack align="center">
          <Stack.Item grow color="label">
            Log in with your ID to buy. Heads of staff can spend their department budget, cargo staff the supply
            budget and sell to traders.
          </Stack.Item>
          <Stack.Item>
            <Button icon="id-card" onClick={() => act('login')}>
              Log in
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
  const payers = data.payers || [];
  const current = data.paying_department || null;
  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow>
          <Box inline bold mr={2}>
            {data.owner}
          </Box>
          {data.pending_orders > 0 && (
            <Box inline color="label">
              Orders waiting for delivery: {data.pending_orders}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button icon="sign-out-alt" onClick={() => act('logout')}>
            Log out
          </Button>
        </Stack.Item>
      </Stack>
      <Box mt={1}>
        <Box inline color="label" mr={1}>
          Pay from:
        </Box>
        {payers.map((payer) => (
          <Button
            key={payer.id || 'personal'}
            selected={payer.id === current}
            onClick={() => act('set_payer', { department: payer.id })}
          >
            {payer.name}, {payer.balance} cr
          </Button>
        ))}
      </Box>
    </Section>
  );
};

const TradersTab = () => {
  const { data } = useBackend<Data>();
  const [selected, setSelected] = useState<string | null>(null);
  const trader =
    data.traders.find((entry) => entry.id === selected) || data.traders[0];
  return (
    <Stack fill vertical>
      <Stack.Item>
        <NoticeBox info>
          <Icon name="shuttle-van" mr={1} />
          {data.freighter}
        </NoticeBox>
      </Stack.Item>
      <Stack.Item grow>
        <TradersList trader={trader} setSelected={setSelected} />
      </Stack.Item>
    </Stack>
  );
};

const TradersList = (props: {
  trader: Trader | undefined;
  setSelected: (id: string) => void;
}) => {
  const { data } = useBackend<Data>();
  const { trader, setSelected } = props;
  return (
    <Stack fill>
      <Stack.Item width="28%">
        <Section fill scrollable title="In contact">
          {data.traders.map((entry) => (
            <Button
              key={entry.id}
              fluid
              icon={entry.icon}
              color={entry.contraband ? 'red' : undefined}
              selected={trader?.id === entry.id}
              onClick={() => setSelected(entry.id)}
            >
              {entry.name}
            </Button>
          ))}
          {data.away_count > 0 && (
            <Box color="label" mt={1}>
              {data.away_count} more trader{data.away_count > 1 ? 's' : ''} may
              come back after the next market shift.
            </Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        {trader ? (
          <TraderPanel trader={trader} />
        ) : (
          <NoticeBox>No traders are in contact right now.</NoticeBox>
        )}
      </Stack.Item>
    </Stack>
  );
};

const TraderPanel = (props: { trader: Trader }) => {
  const { act, data } = useBackend<Data>();
  const { trader } = props;
  const [amounts, setAmounts] = useState<Record<string, number>>({});
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={trader.name}
          buttons={
            data.cargo_access ? (
              <Button
                icon="print"
                onClick={() => act('consignment', { ref: trader.id })}
              >
                Print consignment note
              </Button>
            ) : undefined
          }
        >
          <Box color="label" italic>
            {trader.title}. {trader.desc}
          </Box>
          <Box mt={1} p={1} backgroundColor="rgba(0, 0, 0, 0.3)">
            <Box inline bold color={trader.color} mr={1}>
              {trader.name}:
            </Box>
            &quot;{trader.message}&quot;
          </Box>
          <Box mt={0.5} color={trader.patience > 1 ? 'label' : 'bad'}>
            {trader.patience > 0
              ? `Will haggle ${trader.patience} more time${trader.patience > 1 ? 's' : ''}.`
              : 'Will not haggle any more. One more try and they leave.'}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="For sale">
          <Table>
            <Table.Row header>
              <Table.Cell>Goods</Table.Cell>
              <Table.Cell textAlign="right">Price</Table.Cell>
              <Table.Cell textAlign="right">Left</Table.Cell>
              <Table.Cell textAlign="right">Amount</Table.Cell>
              <Table.Cell />
            </Table.Row>
            {trader.selling.map((offer) => {
              const amount = Math.min(
                amounts[offer.ref] || 1,
                offer.stock < 0 ? 99 : offer.stock,
              );
              return (
                <Table.Row key={offer.ref} className="candystripe">
                  <Table.Cell>{offer.name}</Table.Cell>
                  <Table.Cell textAlign="right" color={offer.haggled ? 'good' : undefined}>
                    {offer.price} cr
                  </Table.Cell>
                  <Table.Cell textAlign="right">
                    {offer.stock < 0 ? '-' : offer.stock}
                  </Table.Cell>
                  <Table.Cell textAlign="right">
                    <NumberInput
                      width="50px"
                      value={amount}
                      minValue={1}
                      maxValue={offer.stock < 0 ? 99 : Math.max(offer.stock, 1)}
                      step={1}
                      onChange={(value) =>
                        setAmounts({ ...amounts, [offer.ref]: Math.round(value) })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell textAlign="right" collapsing>
                    <Button
                      icon="cart-plus"
                      disabled={!data.logged_in}
                      onClick={() => act('buy', { ref: offer.ref, amount })}
                    >
                      Buy for {offer.price * amount}
                    </Button>
                    <Button
                      icon="comments-dollar"
                      disabled={!data.logged_in}
                      onClick={() => act('haggle', { ref: offer.ref })}
                    >
                      Haggle
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item height="35%">
        <Section fill scrollable title="Buying from the station">
          <Table>
            <Table.Row header>
              <Table.Cell>Goods</Table.Cell>
              <Table.Cell textAlign="right">Pays</Table.Cell>
              <Table.Cell textAlign="right">Wants</Table.Cell>
              <Table.Cell />
            </Table.Row>
            {trader.buying.map((offer) => (
              <Table.Row key={offer.ref} className="candystripe">
                <Table.Cell>
                  {offer.name}
                  {offer.in_demand && (
                    <Box inline ml={1} color="good" bold>
                      IN DEMAND
                    </Box>
                  )}
                </Table.Cell>
                <Table.Cell textAlign="right" color={offer.haggled ? 'good' : undefined}>
                  {offer.price} cr
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {offer.stock < 0 ? 'any' : offer.stock}
                </Table.Cell>
                <Table.Cell textAlign="right" collapsing>
                  <Button
                    icon="comments-dollar"
                    disabled={!data.cargo_access}
                    onClick={() => act('haggle', { ref: offer.ref })}
                  >
                    Haggle
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MarketTab = () => {
  const { data } = useBackend<Data>();
  const { market } = data;
  const [selected, setSelected] = useState<string | null>(null);
  const categories = Array.from(
    new Set(market.commodities.map((entry) => entry.category)),
  );
  const [category, setCategory] = useState<string | null>(null);
  const shown = market.commodities.filter(
    (entry) => !category || entry.category === category,
  );
  const commodity = market.commodities.find((entry) => entry.id === selected);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <NoticeBox info>
          Prices change in {formatTime(market.next_shift)}. New CentCom supply
          requests pay from {Math.round(market.quest_min * 100)}% to{' '}
          {Math.round(market.quest_max * 100)}% depending on the price of what
          they ask for.
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <Button selected={!category} onClick={() => setCategory(null)}>
          All
        </Button>
        {categories.map((name) => (
          <Button
            key={name}
            selected={category === name}
            onClick={() => setCategory(name)}
          >
            {name}
          </Button>
        ))}
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <Section fill scrollable>
              <Table>
                <Table.Row header>
                  <Table.Cell>Goods</Table.Cell>
                  <Table.Cell>Category</Table.Cell>
                  <Table.Cell textAlign="right">Price</Table.Cell>
                  <Table.Cell textAlign="right">vs. usual</Table.Cell>
                </Table.Row>
                {shown.map((entry) => {
                  const change = Math.round(
                    (entry.price / entry.base_price - 1) * 100,
                  );
                  return (
                    <Table.Row
                      key={entry.id}
                      className="candystripe"
                      onClick={() => setSelected(entry.id)}
                      style={{ cursor: 'pointer' }}
                    >
                      <Table.Cell bold={entry.id === selected}>
                        {entry.name}
                        {entry.in_demand && (
                          <Box inline ml={1} color="good" bold>
                            IN DEMAND
                          </Box>
                        )}
                      </Table.Cell>
                      <Table.Cell color="label">{entry.category}</Table.Cell>
                      <Table.Cell textAlign="right">
                        {entry.price} cr / {entry.unit}
                      </Table.Cell>
                      <Table.Cell
                        textAlign="right"
                        color={change > 0 ? 'good' : change < 0 ? 'bad' : 'label'}
                      >
                        {change > 0 ? '+' : ''}
                        {change}%
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            </Section>
          </Stack.Item>
          <Stack.Item width="35%">
            <Section fill title={commodity ? commodity.name : 'Price history'}>
              {commodity ? (
                <Stack fill vertical>
                  <Stack.Item color="label">
                    {commodity.desc ||
                      `Usual price ${commodity.base_price} cr per ${commodity.unit}.`}
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box position="relative" height="100%">
                      <Chart.Line
                        fillPositionedParent
                        data={commodity.history.map((value, index) => [
                          index,
                          value,
                        ])}
                        rangeX={[0, Math.max(commodity.history.length - 1, 1)]}
                        rangeY={[0, Math.max(...commodity.history) * 1.1]}
                        strokeColor="rgba(219, 160, 40, 1)"
                        fillColor="rgba(219, 160, 40, 0.2)"
                      />
                    </Box>
                  </Stack.Item>
                </Stack>
              ) : (
                <Box color="label">Select goods to see their price history.</Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
