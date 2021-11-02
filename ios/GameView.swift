//
//  GameView.swift
//  Takeoff
//
//  Created by Christoph Knes on 11.02.21.
//

import Resolver
import SwiftUI

struct GameView: View {
    var gameId: String

    @InjectedStateObject private var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Group {
                GameBackgroundVideoView()
                    .edgesIgnoringSafeArea(.all)

                 if viewModel.reviewViewVisible {
                     GameReviewView()
                 } else if viewModel.discordViewVisible {
                     GameDiscordView()
                 } else {
                     GameHeaderView()
                         .zIndex(2)

                     Group {
                         switch viewModel.game?.state {
                         case .opened:
                             GameOpenedView()
                                 .zIndex(1)
                         case .start:
                             GameStartView()
                                 .zIndex(1)
                         case .preparation:
                             GamePreparationView()
                                 .zIndex(3)
                         case .question, .answerReveal:
                             GameQuestionView()
                                 .zIndex(1)
                         case .end:
                             endView
                         default:
                             EmptyView()
                         }
                     }

                     GamePageView()
                         .zIndex(4)

                     GameChatTextFieldView()
                         .zIndex(5)
                 }
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            viewModel.load(gameId: gameId)
        }
        .onReceive(viewModel.$spectatorModeEnabled) { spectatorModeEnabled in
            if spectatorModeEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showModal(
                        id: .SpectatorMode,
                        symbol: .emoji("🕵️‍♂️"),
                        title: String(key: "game_spectator_mode_modal_title"),
                        text: String(key: "game_spectator_mode_modal_text")
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var endView: some View {
        if let compositionPlayer = viewModel.endGameCompositionPlayer {
            PlayerView(
                compositionPlayer: compositionPlayer
            )
            .zIndex(6)
            .edgesIgnoringSafeArea(.all)
        }

        if viewModel.shareViewVisible {
            GameShareView()
                .opacity(viewModel.endGameVideoEnded ? 1 : 0)
                .zIndex(5)
        } else {
            GameEndView()
                .zIndex(1)

            GameEndModalView()
                .zIndex(6)
        }
    }
}
