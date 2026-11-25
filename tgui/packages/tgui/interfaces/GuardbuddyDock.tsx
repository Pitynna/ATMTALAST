import {
	Button,
	Dropdown,
	LabeledList,
	NoticeBox,
	ProgressBar,
	Section,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface DockData {
	powered: boolean;
	authorized: boolean;
	security: boolean;
	command: boolean;
	order_zone: string | null;
	last_threat: string | null;
	threat_age: number | null;
	assigned: boolean;
	docked: boolean;
	connected: boolean;
	blocked: boolean;
	name: string | null;
	program: string | null;
	charge: number | null;
	cell: boolean;
	tool: string | null;
	mixture: string | null;
	tool_error: string | null;
	zone: string | null;
	mode: string | null;
	reason: string | null;
	target: string | null;
	candidates: { value: string; displayText: string }[];
	zones: { value: string; displayText: string }[];
}

const programs = [
	{ key: 'standby', name: 'Standby' },
	{ key: 'patrol', name: 'Patrol' },
];

const assignments: Record<string, string> = {
	standby: 'Standby',
	patrol: 'Patrol',
	escort: 'Escort',
	secure: 'Hold post',
	areaguard: 'Guard area',
	bodyguard: 'Bodyguard',
	purge: 'Purge',
};

export const GuardbuddyDock = () => {
	const { act, data } = useBackend<DockData>();
	const {
		powered,
		authorized,
		security,
		command,
		order_zone,
		last_threat,
		threat_age,
		assigned,
		docked,
		connected,
		blocked,
		name,
		program,
		charge,
		cell,
		tool,
		mixture,
		tool_error,
		zone,
		mode,
		reason,
		target,
		candidates,
		zones,
	} = data;
	const canControl = powered && (authorized || security);
	const canConfigure = canControl && docked && !blocked;
	const canDispatch =
		canConfigure &&
		(program === 'purge'
			? command
			: program === 'secure' ||
				  program === 'areaguard' ||
				  program === 'bodyguard'
				? security
				: authorized);

	return (
		<Window width={460} height={340}>
			<Window.Content scrollable>
				{!powered && (
					<NoticeBox danger>Dock power unavailable.</NoticeBox>
				)}
				{!authorized && !security && (
					<NoticeBox>
						Robotics access required for controls.
					</NoticeBox>
				)}
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
								disabled={!powered || !authorized || !blocked}
								onClick={() => act('pair')}
							>
								Pair
							</Button>
						)
					}
				>
					{!assigned ? (
						<NoticeBox>
							Pull one unpaired Guardbuddy onto the pad.
						</NoticeBox>
					) : (
						<LabeledList>
							<LabeledList.Item label="Status">
								{mode ?? 'Signal lost'}
							</LabeledList.Item>
							{zone && (
								<LabeledList.Item label="Location">
									{zone}
								</LabeledList.Item>
							)}
							{charge !== null && (
								<LabeledList.Item label="Battery">
									{cell ? (
										<ProgressBar
											value={charge}
											minValue={0}
											maxValue={100}
										>
											{charge}%
										</ProgressBar>
									) : (
										'No cell'
									)}
								</LabeledList.Item>
							)}
							{program && (
								<LabeledList.Item label="Module">
									{tool ?? 'Empty'}
								</LabeledList.Item>
							)}
							{mixture && (
								<LabeledList.Item label="Reagents">
									{mixture}
								</LabeledList.Item>
							)}
							{tool_error && (
								<LabeledList.Item label="Module status">
									{tool_error}
								</LabeledList.Item>
							)}
							{target && (
								<LabeledList.Item label="Crewmember">
									{target}
								</LabeledList.Item>
							)}
							{program && (
								<LabeledList.Item label="Assignment">
									{assignments[program]}
									{order_zone && ' — ' + order_zone}
								</LabeledList.Item>
							)}
							{last_threat && (
								<LabeledList.Item label="Last detected threat">
									{last_threat} ({threat_age}s ago)
								</LabeledList.Item>
							)}
							{reason && (
								<LabeledList.Item label="Last stop">
									{reason}
								</LabeledList.Item>
							)}
						</LabeledList>
					)}
				</Section>
				{assigned && (
					<Section title="Assignment">
						{programs.map(({ key, name }) => (
							<Button
								key={key}
								selected={program === key}
								disabled={!canConfigure || !authorized}
								onClick={() => act('program', { program: key })}
							>
								{name}
							</Button>
						))}
						{canConfigure && authorized && (
							<Dropdown
								options={candidates}
								placeholder="Select a crewmember to escort"
								onSelected={(target) =>
									act('program', {
										program: 'escort',
										target,
									})
								}
							/>
						)}
						{canConfigure && security && (
							<Section title="Security orders">
								<Button
									onClick={() =>
										act('program', { program: 'secure' })
									}
								>
									Hold my position
								</Button>
								<Dropdown
									options={candidates}
									placeholder="Select a crewmember to protect"
									onSelected={(target) =>
										act('program', {
											program: 'bodyguard',
											target,
										})
									}
								/>
								<Dropdown
									options={zones}
									placeholder="Select an area to guard"
									onSelected={(target) =>
										act('program', {
											program: 'areaguard',
											target,
										})
									}
								/>
								{command && (
									<Dropdown
										options={zones}
										placeholder="Select an area to purge"
										onSelected={(target) =>
											act('program', {
												program: 'purge',
												target,
											})
										}
									/>
								)}
							</Section>
						)}
						<Button
							icon="play"
							disabled={
								!canDispatch || !cell || (charge ?? 0) <= 20
							}
							onClick={() => act('dispatch')}
						>
							Dispatch
						</Button>
						<Button
							icon="unlink"
							disabled={!canConfigure || !authorized}
							onClick={() => act('unpair')}
						>
							Unpair
						</Button>
						{blocked && (
							<NoticeBox>The charging pad is occupied.</NoticeBox>
						)}
					</Section>
				)}
			</Window.Content>
		</Window>
	);
};
