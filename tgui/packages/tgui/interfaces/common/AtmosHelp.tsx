import { Icon, Tooltip } from 'tgui-core/components';

export const HoverHelp = ({ content }: { content: string }) => (
  <Tooltip content={content}>
    <Icon name="question-circle" width="12px" mr="6px" />
  </Tooltip>
);

export const HelpDummy = () => <Icon name="" width="12px" mr="6px" />;
