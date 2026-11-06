import { useAtomValue } from 'jotai';
import {
  Box,
  Button,
  NoticeBox,
  RoundGauge,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';
import { metaAtom } from './atoms';
import { hideDonations } from './handlers';

export const Donations = (props: unknown) => {
  const donation = useAtomValue(metaAtom);
  if (!donation) return null;
  const currentValue = donation.monthDonations;
  const maxValue = Math.max(1, donation.targetDonation);
  const middleValue = 0.8 * maxValue;
  const infoText = donation.donationsText;
  const boostyRef = donation.boostyUrl;
  const kofiRef = donation.kofiUrl;
  const discordRef = donation.discordUrl;

  const createMarkup = (html) => {
    return { __html: decodeHtmlEntities(html) };
  };

  return (
    <Section className="Donation__Section" fill title="  ">
      <div className="Section__buttons">
        {
          <Button
            icon="close"
            backgroundColor="red"
            onClick={() => {
              hideDonations();
            }}
          />
        }
      </div>
      <Stack fill px={2} py={1}>
        <Stack.Item
          width="35%"
          style={{ textAlign: 'center', alignContent: 'center' }}
        >
          <RoundGauge
            value={currentValue}
            size={4.5}
            minValue={0}
            maxValue={maxValue}
            format={(value) =>
              `${value} из ${maxValue} ₽ (${Math.round((value / maxValue) * 100)}%)`
            }
            ranges={{
              bad: [0, middleValue],
              average: [middleValue, 0.97 * maxValue],
              good: [0.97 * maxValue, maxValue],
            }}
          />
        </Stack.Item>
        <Stack.Item width="65%" pr={1.5}>
          <Stack vertical>
            <Stack.Item>
              <NoticeBox color="purple">
                <Box dangerouslySetInnerHTML={createMarkup(infoText)} />
              </NoticeBox>
            </Stack.Item>
            <Stack.Item style={{ textAlign: 'center' }}>
              <Section fitted noTopPadding fill title="Поддержать сервер">
                <Stack fill style={{ justifyContent: 'center' }}>
                  <Stack.Item>
                    <a href={kofiRef || undefined} aria-disabled={!kofiRef}>
                      <Box className="Donation_Image Kofi__Image" />
                    </a>
                  </Stack.Item>
                  <Stack.Item>
                    <a href={boostyRef || undefined} aria-disabled={!boostyRef}>
                      <Box className="Donation_Image Boosty__Image" />
                    </a>
                  </Stack.Item>
                  <Stack.Item>
                    <a href={discordRef || undefined} aria-disabled={!discordRef}>
                      <Box className="Donation_Image Discord__Image" />
                    </a>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
