//
//  GameViewModel.swift
//  Takeoff
//
//  Created by Christoph Knes on 24.08.21.
//

import Combine
import Resolver

final class GameViewModel: ObservableObject {
    @Injected private var userRepository: UserRepository
    @Injected private var authService: AuthService

    private var gameRepository = GameRepository()

    private var cancellables = Set<AnyCancellable>()

    func load(gameId: String) {
        gameRepository.addListener(gameId)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] game in
                self?.game = game
            }
            .store(in: &cancellables)
    }
}