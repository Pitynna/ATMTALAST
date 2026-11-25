import { Button, NoticeBox, Section } from 'tgui-core/components';
import { useBackend } from '../../backend';

interface Buddy {
	uid: string;
	name: string;
	zone: string;
	summoned: boolean;
	recalling: boolean;
}

export const pda_guardbuddy = () => {
	const { act, data } = useBackend<{ guardbuddies: Buddy[] }>();
	const { guardbuddies = [] } = data;

	if (!guardbuddies.length) {
		return <NoticeBox>No Guardbuddies in range.</NoticeBox>;
	}

	return guardbuddies.map(({ uid, name, zone, summoned, recalling }) => (
		<Section key={uid} title={name}>
			{zone}
			{recalling ? (
				<NoticeBox>Returning to home dock.</NoticeBox>
			) : (
				<Button
					icon={summoned ? 'stop' : 'location-arrow'}
					onClick={() => act(summoned ? 'cancel' : 'summon', { uid })}
				>
					{summoned ? 'Cancel call' : 'Summon'}
				</Button>
			)}
		</Section>
	));
};
