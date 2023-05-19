# Notes for task 10

## Architecture Deep Dive Part 1
- As a Solutions Architect, it is important for us to know different types of architectures in order to design an adequate architectural solution
- Event Driven Architecture example (video streaming app):
    - User uploads a 4K video
    - The platform processes this video and generates different quality versions of the original video - 1080p, 720p, 480p...
    - This is the Processing part of the application, but it is the most resource-intensive one
- There are a few ways we can architect this platform

1. Monolithic Architecture
    - Historically, the most popular architecture was known as Monolithic Architecture
    - Single black box with entire platform within it - Upload, Processing and Storage components
    - Fails together - Logically separate, but if one fails, everything fails
    - Scales together - need to vertically scale, when scaling one, everything scales
    - Bills together - all components are always running, therefore all components always generate cost

2. Tiered Architecture
    - We can break up the Monolith into different tiers
    - Each tier can represent different components
    - Components can be on different servers
    - Components are still coupled together completely - each tier sends data directly to an endpoint of another tier
    - Benefit vs. Monolith - tiers can be vertically scaled independently
    - We can further evolve this architecture by putting internal load balancers between the tiers, so that the endpoints do not communicate directly with one another
    - Flaws of this architecture:
        - Components still coupled - e.g. Upload component both expects and requires the Processing component to respond
        - Each tier has to be running something for the app to work

## Architecture Deep Dive Part 2
- The previously mentioned architectures can be evolved with queues
- Queue - system that accepts messages sent to it and can relay those messages elsewhere
- In many queues, there is ordering
- Usually, queues use FIFO - First In, First Out
- Using the queue-based decoupled architecture, the video streaming app from the example before would look like this:
    - User uploads the video to the Upload component
    - Instead of passing it directly to the Processing component, the Upload component does something slightly different - it stores the master 4K video in the S3 bucket and adds a message to the queue regarding where the video is stored, its size etc.
    - The message is added to the front of the queue
    - The Upload component has now finished with this particular transaction and does not need to do anything further
    - It doesn't talk directly to the Processing tier and does not know or care whether it is responding
    - Due to this, the Upload component can now be reused
    - On the other side of this queue, we have an ASG that scales based on the queue length
    - Once instances are provisioned, they start polling the queue and receive messages in the order they were added to the queue
    - The instances retrieve the master video from the S3 bucket to perform the processing on them
    - Once done, the ASG scales back one the queue length shortens

3. Microservice Architecture
    - If we keep breaking the architectures like this further and further, we end up with Microservice Architectures
    - As the name suggests, it is a collection of microservices
    - In this case, we have an Upload, Process and Store and Manage microservices
    - Upload - producer (produces data or messages)
    - Process - consumer (consumes data or messages)
    - Store and Manage - both
    - Usually, they produce and consume events, which can be communicated via queues
    - Event-driven architecture - applications which rely on events to and use event producers and event consumers to function
    - Producers and consumers do not sit around waiting for something to happen - they work only when reacting to an event, and stop as soon as they are done with their job, avoiding unneccessary resource consumption
    - The applications would get extremely complicated if they needed to be aware of every other component and if each needed a singular queue between them
    - Solution - Event Router - highly available central exchange point for events
    - Event Router has an Event Bus - constant flow of events

## AWS Lambda Part 1
- FaaS - Function as a Service - short-running & focused code
- Lambda takes care of running that code and providing output
- Functions use a runtime (e.g. Python 3.8)
- Functions are loaded and run in a runtime environment
- The environment has a direct memory (indirect CPU) allocation (based on the amount of memory we decide on, certain amount of CPU is allocated)
- User is billed for the duration of function's execution
- A key part of Serverless Architectures
- Lambda function - the code of the function, it's associated runtime environment and allocated resources for the environment
- Common runtimes - Python, Ruby, Java, Go, C#
- Temporary storage available in /tmp - between 512MB and 10240MB
- Function timeout - 900s(15m)
- Lambda function requires attaching an IAM role that allows it to interact with other AWS resources
- Serverless applications are often delivered by S3, API Gateway and Lambda
- File processing: S3, S3 Events, Lambda
- Database triggers: DynamoDB, Streams, Lambda
- Serverless CRON: EventBridge + Lambda
- Realtime Stream Data Processing: Kinesis + Lambda

## AWS Lambda Part 2
- By default, Lambda functions are given public networking - They can access public AWS services and public internet
- Public networking offers best performance because no customer-specific VPC networking is required
- Lambda functions have no access to VPC-based services unless public IPs are provided & security controls allow external access
- Private Lambda - Lambda configured to run in a private subnet
- Lambda functions running in a VPC obey all VPC networking rules, so they should be treated as any other networked component in a VPC (we can use VPC Endpoint to provide it access to public AWS services, or NAT GW + IGW to provide it access to the internet)
- Previously, an EIP was required for each Lambda communication to any element in a VPC
- Now, we can use a single EIP for all connection
- Lambda execution roles are IAM roles attached to Lambda functions which control permissions the Lambda function receives
- Logging:
    - Lambda uses CloudWatch, CW Logs and X-Ray
    - Logs from Lambda executions - CW logs
    - Metrics - CW
    - Can be integrated with X-Ray for distributed tracing
    - CW Logs requires permissions via execution role

## AWS Lambda Part 3
- Three different methods for Lambda invocation:
1. Synchronous invocation
    - With this method, we can use CLI/API to directly invoke a Lambda function, passing in data and waiting for a response
    - Lambda function responds with data or fail message
    - We can also use this method by utilizing API Gateway, where the client communicates with API GW, which proxies this communication to Lambda
    - Function is ran once. Any issues and the client needs to re-run calls.
    - This method is usually used when there is a human direectly or indirectly invoking a Lambda function
2. Asynchronous invocation
    - Typically used when AWS services invoke Lambda functions
    - For example, uploading to S3 triggers an event which calls a Lambda function
    - S3, in this case, isn't waiting for any response
    - Lambda usually processes the data and does something further with it
    - In case of failure, Lambda is responsible for reprocessing
    - The Lambda process needs to be idempotent (it can safely retry without endangering data integrity)
    - For this, we configure Lambda to try to finalize with a desired state
3. Event source mappings
    - Typically used for streams or queues which don't support event generation to invoke Lambda (Kinesis, DynamoDB streams, SQS)
    - Producers communicate with a data stream, which does not cause events but instead creates batches that Lambda function polls for invocation

- Lambda Versions
    - Lambda functions have versions - v1, v2, v3...
    - A version of the code + the configuration of the Lambda function
    - It's immutable - it never changes once published and has its own Amazon Resource Name (ARN)
    - $Latest - points to the latest version
    - Aliases (DEV, STAGE, PROD) point at a version - can be changed

- Lambda startup times
    - Lambda code runs in a runtime environment (also known as execution context)
    - When calling a function, the execution context needs to be created and runtime packages need to be downloaded and installed
    - This takes time, and this process is known as a cold start
    - For future invocations, the same execution context used for a previous function execution can be re-used, which is known as a warm-start
    - In warm start, the execution context is already prepared, so the function is executed faster
    - Provisioned concurrency can be used, where an X amount of execution context can be kept warm and ready to use

## CludWatchEvents and Event Bridge
- CW Events and EventBridge share the same underlying architecture and set of functionalities, but EventBridge is more advanced and has additional functionalities of its own
- AWS starting to encourage migration from CW Events to EventBridge
- Key concepts of CW Events / EventBridge:
    - If X happens, or at Y times, do Z
    - EventBridge is CW Events v2
    - There is a default Event bus for the account
    - CW Events has only one bus (implicit)
    - EB can have additional busses
    - Rules match incoming events (or schedules)
    - Route events to 1+ targets (e.g. Lambda)
    - Example event: EC2 instance state change

## Serverless Architecture
- Serverless architecture is commonplace in AWS because AWS provides many products that enable it
- In Serverless Architecture, you manage few, if any, servers, which leads to low overhead
- In serverless, you break down the platform to tiniest components, even beyond microservices
- Applications are collections of small and specialized functions
- Stateless and ephemeral environments - duration billing
- Generally, everything is event-driven - consumption only when being used
- FaaS is used where possible for compute functionality
- Managed services are used where possible

## Simple Notification Service (SNS)
- Public AWS Service - network connectivity with Public Endpoint
- Coordinates the sending and delivery of messages
- Messages are <= 256KB payloads
- You cannot send large files via SNS - architecturally, they are designed for short messages
- SNS Topics are the base entity of SNS - permissions and configuration
- A Publisher sends messages to a topic
- Topics can have subscribers which receive messages
- e.g. HTTP(s), Email(-JSON), SQS, Mobile Push, SMS Messages and Lambda