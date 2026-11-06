import { Box, Button, DmIcon, NoticeBox, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type RecyclerData = {
  glass: number;
  available: boolean;
  products: { id: number; name: string; cost: number; icon: string; icon_state: string }[];
};

export const GlassRecycler = () => {
  const { act, data } = useBackend<RecyclerData>();
  return (
    <Window width={390} height={440}>
      <Window.Content scrollable>
        <Section title="Glass recycler">
          <Box bold>Stored glass: {data.glass}</Box>
          <Box mt={1}>Insert empty glassware, plates, bowls, glass shards or plain glass sheets. Remove any contents or attachments first.</Box>
          {!data.available && <NoticeBox>Close the maintenance panel and restore power to operate.</NoticeBox>}
        </Section>
        <Section title="Make glassware">
          {data.products.map((product) => (
            <Stack key={product.id} align="center" mb={1}>
              <Stack.Item><DmIcon icon={product.icon} icon_state={product.icon_state} width="32px" height="32px" /></Stack.Item>
              <Stack.Item grow>{product.name}</Stack.Item>
              <Stack.Item>
                <Button icon="hammer" disabled={!data.available || data.glass < product.cost} onClick={() => act('create', { id: product.id })}>{product.cost} glass</Button>
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
