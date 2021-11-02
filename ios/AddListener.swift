func addListener(_ query: Query) -> AnyPublisher<[DocumentChangeType: [M]], TakeoffError> {
    return Publishers.QuerySnapshotPublisher(query)
        .flatMap { querySnapshot -> AnyPublisher<[DocumentChangeType: [M]], TakeoffError> in
            do {
                var docsByChangeType = [DocumentChangeType: [M]]()

                try querySnapshot.documentChanges.forEach { docChange in
                    if let doc = try docChange.document.data(as: M.self) {
                        if !docsByChangeType.keys.contains(docChange.type) {
                            docsByChangeType[docChange.type] = []
                        }

                        docsByChangeType[docChange.type]!.append(doc)
                    }
                }

                return Just(docsByChangeType)
                    .setFailureType(to: TakeoffError.self)
                    .eraseToAnyPublisher()
            } catch(let error) {
                return Fail(error: .default(description: error.localizedDescription))
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
}

func addListener(limit: Int? = nil) -> AnyPublisher<[DocumentChangeType: [Game]], TakeoffError> {
    var query = self.db
        .collection(self.collection)
        .whereField("state", isNotEqualTo: Game.State.closed.rawValue)
        .order(by: "state", descending: true)
        .order(by: "scheduledAt")

    if let limit = limit {
        query = query.limit(to: limit)
    }

    return self.addListener(query)
}