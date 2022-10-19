from function_code import counter


def get_counter():
    response = counter.lambda_handler("","")
    return response.json()['body']

def test_counter(monkeypatch):
    visitor_count = 11

    class MockResponse:

        def __init__(self, body):
            self.body = body
        
        def json(self):
            return self.body

    monkeypatch.setattr(
        counter, 
        'lambda_handler', 
        lambda *args, **kwargs: MockResponse({'body': visitor_count})
    )

    assert get_counter() == visitor_count

