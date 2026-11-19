import { useState } from 'react';
import {
  Box,
  Button,
  Chart,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type StockEvent = {
  title: string;
  desc: string;
};

type Company = {
  id: string;
  name: string;
  ticker: string;
  desc: string;
  industry: string;
  price: number;
  last_price: number;
  change: number;
  history: number[];
  bankrupt: boolean;
  events: StockEvent[];
};

type Article = {
  headline: string;
  subtitle: string;
  body: string;
  author: string;
  outlet: string;
  time: string;
  opinion: number;
  ticker: string | null;
};

type Short = {
  ref: string;
  broker: string;
  company: string;
  ticker: string;
  shares: number;
  debt_shares: number;
  deposit: number;
  deposit_rate: number;
  lease_minutes: number;
  grace_minutes: number;
  offer_left: number;
  lease_left: number;
  grace_left: number;
};

type Holding = {
  id: string;
  ticker: string;
  name: string;
  shares: number;
  borrowed: number;
  value: number;
  avg_price: number;
};

type Portfolio = {
  holdings: Holding[];
  shorts: Short[];
  loan_debt: number;
  max_loan: number;
  collateral: number;
  overdue: number;
  log: string[];
};

type Data = {
  companies: Company[];
  offers: Short[];
  news: Article[];
  fee_percent: number;
  min_fee: number;
  max_order: number;
  ltv_percent: number;
  margin_call_percent: number;
  interest_percent: number;
  status: string | null;
  logged_in: boolean;
  owner?: string;
  balance?: number;
  portfolio?: Portfolio;
  acting_for?: string | null;
  payers?: { id: string | null; name: string }[];
};

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${minutes}:${rest < 10 ? '0' : ''}${rest}`;
};

const changeColor = (value: number) =>
  value > 0 ? 'good' : value < 0 ? 'bad' : 'label';

const formatChange = (value: number) =>
  `${value > 0 ? '+' : ''}${value.toFixed(2)}%`;

export const StockExchange = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState(0);
  return (
    <Window width={920} height={660} title="Galactic Exchange">
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
                Portfolio
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                Brokers and loans
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
                News
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 0 && <MarketTab />}
            {tab === 1 && <PortfolioTab />}
            {tab === 2 && <BrokersTab />}
            {tab === 3 && <NewsTab />}
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
            Prices are public. Log in with your ID to trade with your own
            credits. Heads of staff can also invest their department budget.
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
  const overdue = data.portfolio?.overdue || 0;
  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow>
          <Box inline bold mr={2}>
            {data.owner}
          </Box>
          <Box inline color="label" mr={1}>
            {data.acting_for ? `${data.acting_for} budget:` : 'Balance:'}
          </Box>
          <Box inline bold color="good">
            {data.balance} cr
          </Box>
          {overdue > 0 && (
            <Box inline bold color="bad" ml={2}>
              Overdue debt: {overdue} cr
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button icon="sign-out-alt" onClick={() => act('logout')}>
            Log out
          </Button>
        </Stack.Item>
      </Stack>
      {(data.payers?.length || 0) > 1 && (
        <Box mt={1}>
          <Box inline color="label" mr={1}>
            Trade for:
          </Box>
          {data.payers?.map((payer) => (
            <Button
              key={payer.id || 'personal'}
              selected={payer.id === (data.acting_for || null)}
              onClick={() => act('set_payer', { department: payer.id })}
            >
              {payer.name}
            </Button>
          ))}
        </Box>
      )}
    </Section>
  );
};

const MarketTab = () => {
  const { data } = useBackend<Data>();
  const [selected, setSelected] = useState<string | null>(null);
  const company =
    data.companies.find((entry) => entry.id === selected) || data.companies[0];
  return (
    <Stack fill>
      <Stack.Item width="40%">
        <Section fill scrollable title="Listed companies">
          <Table>
            <Table.Row header>
              <Table.Cell>Symbol</Table.Cell>
              <Table.Cell>Company</Table.Cell>
              <Table.Cell textAlign="right">Price</Table.Cell>
              <Table.Cell textAlign="right">Change</Table.Cell>
            </Table.Row>
            {data.companies.map((entry) => (
              <Table.Row
                key={entry.id}
                className="candystripe"
                onClick={() => setSelected(entry.id)}
                style={{ cursor: 'pointer' }}
              >
                <Table.Cell bold color={company?.id === entry.id ? 'average' : undefined}>
                  {entry.ticker}
                </Table.Cell>
                <Table.Cell>{entry.name}</Table.Cell>
                <Table.Cell textAlign="right">{entry.price.toFixed(2)}</Table.Cell>
                <Table.Cell textAlign="right" color={changeColor(entry.change)}>
                  {formatChange(entry.change)}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        {company ? <CompanyPanel company={company} /> : <NoticeBox>No companies are listed.</NoticeBox>}
      </Stack.Item>
    </Stack>
  );
};

const CompanyPanel = (props: { company: Company }) => {
  const { act, data } = useBackend<Data>();
  const { company } = props;
  const [amount, setAmount] = useState(10);
  const held =
    data.portfolio?.holdings.find((entry) => entry.id === company.id)?.shares ||
    0;
  const history = company.history.map((value, index) => [index, value]);
  const maxValue = Math.max(...company.history, 1);
  const minValue = Math.min(...company.history, maxValue);
  const estimate = Math.round(amount * company.price);
  const fee = Math.max(data.min_fee, Math.round((estimate * data.fee_percent) / 100));
  const news = data.news.filter((article) => article.ticker === company.ticker);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title={`${company.name} (${company.ticker})`}>
          <Box color="label" mb={1}>
            {company.industry}. {company.desc}
          </Box>
          <LabeledList>
            <LabeledList.Item label="Price">
              <Box inline bold>
                {company.price.toFixed(2)} cr
              </Box>
              <Box inline ml={1} color={changeColor(company.change)}>
                {formatChange(company.change)} over 5 min
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Chart range">
              {minValue.toFixed(2)} to {maxValue.toFixed(2)} cr
            </LabeledList.Item>
            {data.logged_in && (
              <LabeledList.Item label="You hold">{held} shares</LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item height="160px">
        <Section fill>
          <Chart.Line
            fillPositionedParent
            data={history}
            rangeX={[0, Math.max(history.length - 1, 1)]}
            rangeY={[minValue * 0.95, maxValue * 1.05]}
            strokeColor="rgba(32, 177, 66, 1)"
            fillColor="rgba(32, 177, 66, 0.2)"
          />
        </Section>
      </Stack.Item>
      {data.logged_in && (
        <Stack.Item>
          <Section title="Trade">
            <Stack align="center">
              <Stack.Item>
                <NumberInput
                  width="80px"
                  value={amount}
                  minValue={1}
                  maxValue={data.max_order}
                  step={1}
                  unit="shares"
                  onChange={(value) => setAmount(Math.round(value))}
                />
              </Stack.Item>
              <Stack.Item grow color="label">
                About {estimate} cr, fee {fee} cr
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="cart-plus"
                  color="good"
                  onClick={() => act('buy', { id: company.id, amount })}
                >
                  Buy
                </Button>
                <Button
                  icon="hand-holding-usd"
                  color="bad"
                  disabled={held < 1}
                  onClick={() => act('sell', { id: company.id, amount })}
                >
                  Sell
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Section fill scrollable title="Company news">
          {company.events.map((event) => (
            <NoticeBox key={event.title} color="average">
              <Box bold>{event.title}</Box>
              {event.desc}
            </NoticeBox>
          ))}
          {news.length === 0 && company.events.length === 0 && (
            <Box color="label">Nothing new about this company.</Box>
          )}
          {news.map((article, index) => (
            <ArticleView key={index} article={article} />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ArticleView = (props: { article: Article }) => {
  const { article } = props;
  return (
    <Box mb={1.5}>
      <Box bold color={changeColor(article.opinion)}>
        {article.headline}
      </Box>
      <Box italic color="label">
        {article.subtitle}
      </Box>
      <Box>{article.body}</Box>
      <Box color="label" fontSize="0.9em">
        {article.time} | {article.author}, {article.outlet}
      </Box>
    </Box>
  );
};

const NotLoggedIn = () => (
  <NoticeBox>Log in with your ID to see your account here.</NoticeBox>
);

const PortfolioTab = () => {
  const { act, data } = useBackend<Data>();
  const portfolio = data.portfolio;
  if (!data.logged_in || !portfolio) {
    return <NotLoggedIn />;
  }
  const total = portfolio.holdings.reduce((sum, entry) => sum + entry.value, 0);
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title={`Holdings, worth ${total} cr`}>
          {portfolio.holdings.length === 0 ? (
            <Box color="label">You do not hold any shares.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Symbol</Table.Cell>
                <Table.Cell>Company</Table.Cell>
                <Table.Cell textAlign="right">Shares</Table.Cell>
                <Table.Cell textAlign="right">Borrowed</Table.Cell>
                <Table.Cell textAlign="right">Avg. price</Table.Cell>
                <Table.Cell textAlign="right">Value</Table.Cell>
                <Table.Cell />
              </Table.Row>
              {portfolio.holdings.map((entry) => {
                const company = data.companies.find((c) => c.id === entry.id);
                const profit = company
                  ? (company.price - entry.avg_price) * entry.shares
                  : 0;
                return (
                  <Table.Row key={entry.id} className="candystripe">
                    <Table.Cell bold>{entry.ticker}</Table.Cell>
                    <Table.Cell>{entry.name}</Table.Cell>
                    <Table.Cell textAlign="right">{entry.shares}</Table.Cell>
                    <Table.Cell textAlign="right">{entry.borrowed || '-'}</Table.Cell>
                    <Table.Cell textAlign="right">{entry.avg_price.toFixed(2)}</Table.Cell>
                    <Table.Cell textAlign="right" color={changeColor(profit)}>
                      {entry.value} cr
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      <Button
                        color="bad"
                        onClick={() =>
                          act('sell', {
                            id: entry.id,
                            amount: Math.min(entry.shares, data.max_order),
                          })
                        }
                      >
                        Sell all
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item height="35%">
        <Section fill scrollable title="Recent deals">
          {portfolio.log.length === 0 && <Box color="label">No deals yet.</Box>}
          {portfolio.log.map((line, index) => (
            <Box key={index}>{line}</Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const BrokersTab = () => {
  const { act, data } = useBackend<Data>();
  const portfolio = data.portfolio;
  const [loanAmount, setLoanAmount] = useState(1000);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Broker offers">
          <Box color="label" mb={1}>
            Borrow shares for a deposit and sell them now. When the lease ends
            the shares are taken back from your holdings and the deposit is
            returned. Shares you cannot return by the end of the grace period
            are charged at market price.
          </Box>
          {data.offers.length === 0 ? (
            <Box color="label">No brokers are lending shares right now.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Broker</Table.Cell>
                <Table.Cell>Symbol</Table.Cell>
                <Table.Cell textAlign="right">Shares</Table.Cell>
                <Table.Cell textAlign="right">Deposit</Table.Cell>
                <Table.Cell textAlign="right">Lease</Table.Cell>
                <Table.Cell textAlign="right">Offer ends</Table.Cell>
                <Table.Cell />
              </Table.Row>
              {data.offers.map((offer) => (
                <Table.Row key={offer.ref} className="candystripe">
                  <Table.Cell>{offer.broker}</Table.Cell>
                  <Table.Cell bold>{offer.ticker}</Table.Cell>
                  <Table.Cell textAlign="right">{offer.shares}</Table.Cell>
                  <Table.Cell textAlign="right">
                    {offer.deposit} cr ({offer.deposit_rate}%)
                  </Table.Cell>
                  <Table.Cell textAlign="right">
                    {offer.lease_minutes} + {offer.grace_minutes} min
                  </Table.Cell>
                  <Table.Cell textAlign="right">{formatTime(offer.offer_left)}</Table.Cell>
                  <Table.Cell textAlign="right">
                    <Button
                      disabled={!data.logged_in}
                      onClick={() => act('take_short', { ref: offer.ref })}
                    >
                      Borrow
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>
      {!data.logged_in || !portfolio ? (
        <Stack.Item>
          <NotLoggedIn />
        </Stack.Item>
      ) : (
        <>
          <Stack.Item>
            <Section title="Your short positions">
              {portfolio.shorts.length === 0 ? (
                <Box color="label">You have not borrowed any shares.</Box>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Broker</Table.Cell>
                    <Table.Cell>Symbol</Table.Cell>
                    <Table.Cell textAlign="right">To return</Table.Cell>
                    <Table.Cell textAlign="right">Deposit</Table.Cell>
                    <Table.Cell textAlign="right">Time left</Table.Cell>
                    <Table.Cell />
                  </Table.Row>
                  {portfolio.shorts.map((short) => (
                    <Table.Row key={short.ref} className="candystripe">
                      <Table.Cell>{short.broker}</Table.Cell>
                      <Table.Cell bold>{short.ticker}</Table.Cell>
                      <Table.Cell textAlign="right">
                        {short.debt_shares} / {short.shares}
                      </Table.Cell>
                      <Table.Cell textAlign="right">{short.deposit} cr</Table.Cell>
                      <Table.Cell
                        textAlign="right"
                        color={short.lease_left > 0 ? undefined : 'bad'}
                      >
                        {short.lease_left > 0
                          ? `lease ${formatTime(short.lease_left)}`
                          : `grace ${formatTime(short.grace_left)}`}
                      </Table.Cell>
                      <Table.Cell textAlign="right">
                        <Button onClick={() => act('return_short', { ref: short.ref })}>
                          Return now
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Margin loan">
              <Box color="label" mb={1}>
                Borrow up to {data.ltv_percent}% of the value of your own
                shares. Interest of {data.interest_percent}% is added every 30
                seconds. If the debt grows above {data.margin_call_percent}% of
                your shares, they are sold to cover it.
              </Box>
              <LabeledList>
                <LabeledList.Item label="Debt">
                  <Box inline bold color={portfolio.loan_debt > 0 ? 'bad' : 'good'}>
                    {portfolio.loan_debt} cr
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Collateral">
                  {portfolio.collateral} cr
                </LabeledList.Item>
                <LabeledList.Item label="Can borrow">
                  {portfolio.max_loan} cr
                </LabeledList.Item>
              </LabeledList>
              <Stack mt={1} align="center">
                <Stack.Item>
                  <NumberInput
                    width="100px"
                    value={loanAmount}
                    minValue={1}
                    maxValue={100000}
                    step={100}
                    unit="cr"
                    onChange={(value) => setLoanAmount(Math.round(value))}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="hand-holding-usd"
                    disabled={portfolio.max_loan < 1}
                    onClick={() => act('loan', { amount: loanAmount })}
                  >
                    Borrow
                  </Button>
                  <Button
                    icon="undo"
                    disabled={portfolio.loan_debt + portfolio.overdue < 1}
                    onClick={() => act('repay', { amount: loanAmount })}
                  >
                    Repay
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

const NewsTab = () => {
  const { data } = useBackend<Data>();
  return (
    <Section fill scrollable title="Exchange wire">
      {data.news.length === 0 && <Box color="label">No news yet.</Box>}
      {data.news.map((article, index) => (
        <Box key={index}>
          {!!article.ticker && (
            <Box inline bold color="average" mr={1}>
              [{article.ticker}]
            </Box>
          )}
          <ArticleView article={article} />
        </Box>
      ))}
    </Section>
  );
};
