/// Простой mock поиска пользователя по email.
/// На проде заменяется на GraphQL запрос к Hasura.
class UserSearchService {
  // Пример локального "кеша" для тестирования: email -> userId
  final Map<String, String> _mock = {
    'test@example.com': '0a723c2c-052c-49ee-b1ad-5ee7660b52bb',
    'test@test.com': 'a121f22c-ae4c-4e3c-8ed4-8fcb72368600',
  };

  Future<String?> findUserIdByEmail(String email) async {
    // имитируем задержку
    await Future.delayed(const Duration(milliseconds: 200));
    return _mock[email.toLowerCase()];
  }

  // Для тестов: добавление нового пользователя в mock
  void mockAdd(String email, String userId) {
    _mock[email.toLowerCase()] = userId;
  }
}