import Foundation

final class UserDefaultsStore {

    private let key = "seihai.snapshot.v1"

    func load() -> SeihaiSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(SeihaiSnapshot.self, from: data)
    }

    func save(_ snapshot: SeihaiSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}
