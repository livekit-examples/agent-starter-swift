<img src="./.github/assets/app-icon.png" alt="Voice Agent App Icon" width="100" height="100">

# Swift Voice Agent

This is a starter template for [LiveKit Agents](https://docs.livekit.io/agents/overview/) that provides a simple voice interface using the [LiveKit Swift SDK](https://github.com/livekit/client-sdk-swift). It supports [voice](https://docs.livekit.io/agents/start/voice-ai), [transcriptions](https://docs.livekit.io/agents/build/text/), and [virtual avatars](https://docs.livekit.io/agents/integrations/avatar/).

This template is compatible with iOS, iPadOS, macOS, and visionOS and is free for you to use or modify as you see fit.

<img src="./.github/assets/screenshot.png" alt="Voice Agent Screenshot" height="500">

## Getting started

The easiest way to get this app running is with the [Sandbox for LiveKit Cloud](https://cloud.livekit.io/projects/p_/sandbox) and the [LiveKit CLI](https://docs.livekit.io/home/cli/cli-setup/).

First, create a new [Sandbox Token Server](https://cloud.livekit.io/projects/p_/sandbox/templates/token-server) for your LiveKit Cloud project.

Then, run the following command to automatically clone this template and connect it to LiveKit Cloud.

```bash
lk app create --template voice-agent-swift --sandbox <token_server_sandbox_id>
```

Built and run the app from Xcode by opening `VoiceAgent.xcodeproj`. You may need to adjust your app signing settings to run the app on your device.

You'll also need an agent to speak with. Try our [voice AI quickstart](https://docs.livekit.io/agents/start/voice-ai) for the easiest way to get started.

> [!NOTE]
> To setup without the LiveKit CLI, clone the repository and then either create a `VoiceAgent/.env.xcconfig` with a `LIVEKIT_SANDBOX_ID` (if using a [Sandbox Token Server](https://cloud.livekit.io/projects/p_/sandbox/templates/token-server)), or open `TokenService.swift` and add your [manually generated](#token-generation) URL and token.

## Token generation

In a production environment, you will be responsible for developing a solution to [generate tokens for your users](https://docs.livekit.io/home/server/generating-tokens/) which is integrated with your authentication solution. You should disable your sandbox token server and modify `TokenService.swift` to use your own token server.

## Chat transcription

The app supports agent [transcriptions](https://docs.livekit.io/agents/build/text/). It requires some client-side processing to aggregate the partial results into messages. `TranscriptionStreamReceiver` is responsible for this aggregation. It buffers stream chunks and publishes complete messages when the transcription is finished. Messages have unique IDs and timestamps to help with ordering and display in the UI.

> [!NOTE]
> Text streams are fully supported in LiveKit Agents v1, for v0.x, you'll need to use legacy [transcription events](https://docs.livekit.io/agents/build/text/#transcription-events) as shown in `TranscriptionDelegateReceiver.swift`.

## Contributing

This template is open source and we welcome contributions! Please open a PR or issue through GitHub, and don't forget to join us in the [LiveKit Community Slack](https://livekit.io/join-slack)!

