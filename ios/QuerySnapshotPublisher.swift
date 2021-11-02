//
//  QuerySnapshotPublisher.swift
//  Takeoff
//
//  Created by Christoph Knes on 26.01.21.
//

import Firebase
import FirebaseFirestore
import FirebaseCrashlytics
import SwiftUI
import Combine

extension Publishers {
    struct QuerySnapshotPublisher: Publisher {
        typealias Output = QuerySnapshot
        typealias Failure = TakeoffError

        private let query: Query

        init(_ query: Query) {
            self.query = query
        }

        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let querySnapshotSubscription = QuerySnapshotSubscription(subscriber: subscriber, query: query)
            subscriber.receive(subscription: querySnapshotSubscription)
        }
    }

    class QuerySnapshotSubscription<S: Subscriber> : Subscription
    where S.Input == QuerySnapshot, S.Failure == TakeoffError {
        private var subscriber: S?
        private var listener: ListenerRegistration?

        init(subscriber: S, query: Query) {
            self.subscriber = subscriber
            self.listener = query.addSnapshotListener { [weak self] snapshot, error in
                self?.receive(snapshot: snapshot, error: error)
            }
        }

        private func receive(snapshot: QuerySnapshot?, error: Error?) {
            if let error = error {
                subscriber!.receive(
                    completion: .failure(.default(description: error.localizedDescription))
                )
            } else if let snapshot = snapshot {
                _ = subscriber!.receive(snapshot)
            } else {
                subscriber!.receive(completion: .failure(.default()))
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            listener = nil
        }
    }
}
