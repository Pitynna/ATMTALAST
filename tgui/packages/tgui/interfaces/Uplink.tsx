import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { flow } from 'tgui-core/fp';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type PickTabProps = ShowDescProps & SearchTextProps;

type ShowDescProps = {
  showDesc: boolean;
  setShowDesc: React.Dispatch<React.SetStateAction<boolean>>;
};

const PickTab = (index: number, props: PickTabProps) => {
  switch (index) {
    case 0:
      return <ItemsPage {...props} />;
    case 1:
      return <CartPage {...props} />;
    case 2:
      return <ExploitableInfoPage />;
    case 3:
      return <ObjectivesPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

type UplinkData = {
  cart: Cart[];
  crystals: number;
  cats: Category[];
  cart_price: number;
  lucky_numbers: LuckyNumber[];
  exploitable: ExploitableRecord[];
  objectives_items?: ObjectiveItem[];
};

type Category = {
  items: Item[];
  cat: string;
};

type Item = {
  uid: string;
  name: string;
  desc: string;
  cost: number;
  hijack_only: BooleanLike;
  obj_path: string;
  refundable: BooleanLike;
};

type Cart = {
  name: string;
  obj_path: string;
  cost: number;
  amount: number;
  limit: number;
};

type LuckyNumber = {
  cat: string;
  item: string;
};

type ExploitableRecord = {
  name: string;
  age: number;
  fingerprint: string;
  rank: string;
  sex: string;
  species: string;
  exploit_record: string;
};

type ObjectiveItem = {
  objective_uid: string;
  objective_name: string;
  description: string;
  item_name: string;
  area_name: string;
};

export const Uplink = (_props: unknown) => {
  const { act, data } = useBackend<UplinkData>();
  const { cart } = data;

  const [tabIndex, setTabIndex] = useState(0);
  const [searchText, setSearchText] = useState('');
  const [showDesc, setShowDesc] = useState(true);

  return (
    <Window width={900} height={700} theme="syndicate">
      <ComplexModal maxHeight={50} />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                  setSearchText('');
                }}
                icon="store"
              >
                Магазин
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                  setSearchText('');
                }}
                icon="shopping-cart"
              >
                Корзина {cart?.length ? `(${cart.length})` : ''}
              </Tabs.Tab>
              <Tabs.Tab
                key="ExploitableInfo"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                  setSearchText('');
                }}
                icon="user"
              >
                Информация
              </Tabs.Tab>
              <Tabs.Tab
                key="Objectives"
                selected={tabIndex === 3}
                onClick={() => {
                  setTabIndex(3);
                  setSearchText('');
                }}
                icon="bullseye"
              >
                Снаряжение для целей
              </Tabs.Tab>
              <Tabs.Tab
                key="LockUplink"
                // This cant ever be selected. Its just a close button.
                onClick={() => act('lock')}
                icon="lock"
              >
                Заблокировать
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {PickTab(tabIndex, {
              searchText,
              setSearchText,
              showDesc,
              setShowDesc,
            })}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (properties: SearchTextProps & ShowDescProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useState(cats[0].items);

  const { searchText, setSearchText, showDesc, setShowDesc } = properties;

  const SelectEquipment = (cat: Item[], searchText = '') => {
    const EquipmentSearch = createSearch<Item>(searchText, (item) => {
      const is_hijack = item.hijack_only ? '|' + 'hijack' : '';
      return `${item.name}|${item.desc}|${item.cost}tc${is_hijack}`;
    });
    return flow([
      (cat: Item[]) => cat.filter((item) => !!item?.name), // Make sure it has a name
      (cat: Item[]) => (searchText ? cat.filter(EquipmentSearch) : cat), // Search for anything
      (cat: Item[]) => sortBy(cat, [(item) => item?.name]), // Sort by name
    ])(cat);
  };
  const handleSearch = (value) => {
    setSearchText?.(value);
    if (value === '') {
      return setUplinkItems(cats[0].items);
    }
    setUplinkItems(
      SelectEquipment(
        cats.flatMap((category) => category.items),
        value,
      ),
    );
  };

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={`Текущий баланс: ${crystals} ТК`}
            buttons={
              <>
                <Button.Checkbox
                  checked={showDesc}
                  onClick={() => setShowDesc(!showDesc)}
                >
                  Показывать описание
                </Button.Checkbox>
                <Button icon="question" onClick={() => act('buyRandom')}>
                  Случайный предмет
                </Button>
                <Button icon="undo" onClick={() => act('refund')}>
                  Сделать возврат
                </Button>
              </>
            }
          >
            <Input
              fluid
              placeholder="Поиск..."
              expensive
              onChange={handleSearch}
              value={searchText}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="26%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c, index) => (
                <Tabs.Tab
                  key={index}
                  selected={searchText !== '' ? false : c.items === uplinkItems}
                  onClick={() => {
                    setUplinkItems(c.items);
                    setSearchText?.('');
                  }}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                  mb={0.5}
                  ml={0.5}
                >
                  {c.cat}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {uplinkItems.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.uid)}
                  p={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    key={decodeHtmlEntities(i.uid)}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};

const CartPage = (properties: ShowDescProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { cart, crystals, cart_price } = data;

  const { showDesc, setShowDesc } = properties;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={`Текущий баланс: ${crystals} ТК`}
          buttons={
            <>
              <Button.Checkbox
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              >
                Показывать описание
              </Button.Checkbox>
              <Button
                icon="trash"
                onClick={() => act('empty_cart')}
                disabled={!cart}
              >
                Очистить корзину
              </Button>
              <Button
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > crystals}
              >
                {`Купить корзину (${cart_price}TC)`}
              </Button>
            </>
          }
        >
          <Stack vertical>
            {cart ? (
              cart.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  mr={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    buttons={<CartButtons i={i} />}
                  />
                </Stack.Item>
              ))
            ) : (
              <Box italic>Ваша корзина пуста!</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Advert {...properties} />
    </Stack>
  );
};
const Advert = (properties: ShowDescProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { cats, lucky_numbers } = data;

  const { showDesc } = properties;

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Рекомендуемые товары"
        buttons={
          <Button icon="dice" onClick={() => act('shuffle_lucky_numbers')}>
            Новые рекомендации
          </Button>
        }
      >
        <Stack wrap>
          {lucky_numbers
            .map((number) => cats[number.cat].items[number.item])
            .filter((item) => item !== undefined && item !== null)
            .map((item, index) => (
              <Stack.Item
                key={index}
                p={1}
                mb={1}
                ml={1}
                width={34}
                backgroundColor={'rgba(255, 0, 0, 0.15)'}
              >
                <UplinkItem grow i={item} showDecription={showDesc} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const UplinkItem = (props) => {
  const {
    i,
    showDecription = 1,
    buttons = <UplinkItemButtons i={i} />,
  } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
      <Box mt={2}>{buttons}</Box>
    </Section>
  );
};

type UplinkItemButtonsProps = {
  i: Item;
};

const UplinkItemButtons = (props: UplinkItemButtonsProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { i } = props;
  const { crystals } = data;

  return (
    <>
      <Button
        icon="shopping-cart"
        color={i.hijack_only && 'red'}
        tooltip="Добавить в корзину"
        tooltipPosition="left"
        onClick={() =>
          act('add_to_cart', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
      <Button
        color={i.hijack_only && 'red'}
        // Yes I care this much about both of these being able to render at the same time
        tooltip={
          i.hijack_only &&
          'Только для агентов, имеющих цель — угон эвакуационного шаттла!'
        }
        tooltipPosition="left"
        onClick={() =>
          act('buyItem', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      >
        {'Купить (' +
          i.cost +
          ' ' +
          'ТК)' +
          (i.refundable ? ' [Возвращаемый]' : '')}
      </Button>
    </>
  );
};

type CartButtonsProps = {
  i: Cart;
};

const CartButtons = (props: CartButtonsProps) => {
  const { act } = useBackend();
  const { i } = props;

  return (
    <Stack>
      <Button
        icon="times"
        tooltip="Удалить из корзины"
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      >
        {`(${i.cost * i.amount} ТК)`}
      </Button>
      <Button
        icon="minus"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        ml="5px"
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: --i.amount, // one lower
          })
        }
        disabled={i.amount <= 0}
      />
      <Button.Input
        width="45px"
        tooltipPosition="bottom-end"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        onCommit={(value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
        value={i.amount.toString()}
      />
      <Button
        mb={0.3}
        icon="plus"
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: ++i.amount, // one higher
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit}
      />
    </Stack>
  );
};

const ExploitableInfoPage = (_properties) => {
  const { data } = useBackend<UplinkData>();
  const { exploitable = [] } = data;
  // Default to first
  const [selectedRecord, setSelectedRecord] = useState(exploitable[0]);

  const [searchText, setSearchText] = useState('');

  // Search for peeps
  const SelectMembers = (people: ExploitableRecord[], searchText = '') => {
    const MemberSearch = createSearch<ExploitableRecord>(
      searchText,
      (member: ExploitableRecord) => member?.name,
    );
    return flow([
      (people: ExploitableRecord[]) =>
        // Null member filter
        people.filter((member) => !!member?.name),
      // Optional search term
      (people: ExploitableRecord[]) =>
        searchText ? people.filter(MemberSearch) : people,
      // Slightly expensive, but way better than sorting in BYOND
      (people: ExploitableRecord[]) =>
        sortBy<ExploitableRecord>(people, [
          (member: ExploitableRecord) => member?.name,
        ]),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section fill title="Записи об экипаже">
      <Stack fill>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Input
              fluid
              mb={1}
              placeholder="Поиск..."
              expensive
              onChange={setSearchText}
            />
            <Tabs vertical>
              {crew.map((r) => (
                <Tabs.Tab
                  key={r}
                  selected={r === selectedRecord}
                  onClick={() => setSelectedRecord(r)}
                >
                  {r?.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item grow>
          <Section fill title={selectedRecord?.name} scrollable>
            <LabeledList>
              <LabeledList.Item label="Возраст">
                {selectedRecord.age}
              </LabeledList.Item>
              <LabeledList.Item label="Отпечаток пальцев">
                {selectedRecord.fingerprint}
              </LabeledList.Item>
              <LabeledList.Item label="Должность">
                {selectedRecord.rank}
              </LabeledList.Item>
              <LabeledList.Item label="Пол">
                {selectedRecord.sex}
              </LabeledList.Item>
              <LabeledList.Item label="Раса">
                {selectedRecord.species}
              </LabeledList.Item>
              <LabeledList.Item label="Записи">
                {selectedRecord.exploit_record}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};


const ObjectivesPage = () => {
  const { act, data } = useBackend<UplinkData>();
  const { objectives_items = [] } = data;

  if (!objectives_items.length) {
    return (
      <Section fill title="Снаряжение для целей">
        <Box italic>Нет целей, требующих специального снаряжения</Box>
      </Section>
    );
  }

  return (
    <Section fill scrollable title="Снаряжение для целей">
      {objectives_items.map((objective, index) => (
        <Section
          key={index}
          m={0.2}
          backgroundColor={'rgba(255, 0, 0, 0.1)'}
          title={
            <>
              <Icon name="bullseye" />
              {` Цель: ${objective.objective_name || 'Не указано'}`}
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Описание цели">
              {objective.description || 'Нет описания'}
            </LabeledList.Item>
            <LabeledList.Item label="Предмет для задания">
              <b>{objective.item_name || 'Не указан'}</b>
            </LabeledList.Item>
            <LabeledList.Item label="Место запроса капсулы">
              <Icon name="map-marker-alt" />{' '}
              {objective.area_name || 'Не указано'}
            </LabeledList.Item>
          </LabeledList>
          <Box mt={2}>
            <Button
              icon="box-open"
              color="green"
              onClick={() =>
                act('spawn_objective_item', {
                  obj_uid: objective.objective_uid,
                })
              }
            >
              Запросить предмет
            </Button>
          </Box>
        </Section>
      ))}
    </Section>
  );
};
