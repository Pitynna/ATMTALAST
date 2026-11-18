import { useState } from 'react';
import {
  Box,
  Button,
  Chart,
  NoticeBox,
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

type Data = {
  market: Market;
};

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${minutes}:${rest < 10 ? '0' : ''}${rest}`;
};

export const TradeConsole = () => {
  const [tab, setTab] = useState(0);
  return (
    <Window width={760} height={600} title="Trade Console">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={tab === 0} onClick={() => setTab(0)}>
                Market
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{tab === 0 && <MarketTab />}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
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
