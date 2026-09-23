```mermaid
classDiagram
    class Model {
        +POI
        +User
        +Session
    }

    class Service {
        +POIService
        +UserService
        +PaymentService
    }

    class Controller {
        +POIController
        +UserController
        +PaymentController
    }

    Model <.. Service : sử dụng
    Service <.. Controller : gọi
```
