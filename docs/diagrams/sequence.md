```mermaid
sequenceDiagram
    participant Visitor
    participant System
    participant Admin

    Visitor->>System: Request POI info
    System-->>Visitor: Show POI details
    Visitor->>System: Play Audio Guide
    System-->>Visitor: Stream Audio
    Admin->>System: Update POI data
    System-->>Admin: Confirm update
