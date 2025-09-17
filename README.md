# Back to the Feature

A minimalist open-source feature flags management service with web interface and user system, inspired by Flipper.

## Features

- ✅ **Feature Flag Management** : Create, edit and delete feature flags
- ✅ **Rules System** : Support for boolean, percentage and group-based rules
- ✅ **A/B Testing** : Multiple variants with customizable weights
- ✅ **User Groups** : Define user groups with logical expressions
- ✅ **Web Interface** : Simple and intuitive interface with Tailwind CSS
- ✅ **REST API** : Complete API for external application integration
- ✅ **Authentication** : User system with admin/user roles
- ✅ **Kill Switch** : Instantly disable any flag

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd back_to_the_feature
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Access the application**
   - Open http://localhost:3000
   - Login with `admin` / `password`

## Usage

### Web Interface

1. **Login** : Use the default admin account or create a new account
2. **Flag Management** : Create feature flags with descriptions and variants
3. **Add Rules** : Configure activation rules (boolean, percentage, group)
4. **Group Management** : Define user groups with logical expressions
5. **Administration** : Admins can manage users and their roles

### REST API

#### Authentication
The API uses session authentication. Login first through the web interface or implement API key authentication for production use.

#### Main Endpoints

**List flags**
```bash
GET /api/v1/flags
```

**Create a flag**
```bash
POST /api/v1/flags
Content-Type: application/json

{
  "flag": {
    "name": "new_feature",
    "description": "New feature description",
    "variants": [
      {"name": "control", "weight": 50},
      {"name": "variant", "weight": 50}
    ]
  }
}
```

**Add a rule**
```bash
POST /api/v1/flags/:flag_id/rules
Content-Type: application/json

{
  "rule": {
    "type": "percentage_of_actors",
    "value": "25"
  }
}
```

**Evaluate a flag**
```bash
GET /api/v1/evaluate/:flag_name?user_id=123&user_attributes[email]=user@company.com&user_attributes[role]=premium
```

Or via POST with JSON:
```bash
POST /api/v1/evaluate/:flag_name
Content-Type: application/json

{
  "user_id": 123,
  "user_attributes": {
    "id": 123,
    "email": "user@company.com",
    "username": "john_doe",
    "role": "premium",
    "country": "US",
    "subscription": "pro"
  }
}
```

Response:
```json
{
  "flag_name": "new_feature",
  "variant": "control",
  "enabled": true,
  "rule_type": "percentage_of_actors",
  "rule_id": 42
}
```

### Rule Types

1. **Boolean** : Global activation/deactivation
   - `on` : Enable flag for everyone
   - `off` : Disable flag (kill switch)

2. **Percentage of Actors** : Percentage of users
   - Value: 0-100
   - Uses deterministic hashing of user ID

3. **Group** : User groups
   - References a separately defined group
   - Evaluates the group's logical expression

### Group Expressions

Groups evaluate user attributes sent by client applications:

```ruby
# Users with company email
email.ends_with? "@company.com"

# Admin users
username.starts_with? "admin_"

# Premium users
role == "premium"

# Users from specific country
country == "US"

# Subscription type
subscription == "pro"

# Specific IDs
id.in? [1, 2, 3, 4, 5]
```

**Important:** Groups evaluate attributes provided by the client application via the API. The client application must send all attributes necessary for group evaluation.

## Architecture

### Data Models

- **User** : Users with authentication and roles
- **Flag** : Feature flags with name, description and variants
- **Rule** : Activation rules attached to flags
- **Group** : User groups with logical definitions

### Evaluation Service

The `FlagEvaluationService` evaluates flags with this logic:

1. **Kill switch** : If a `boolean: off` rule exists, disable immediately
2. **Rule order** : Evaluate rules in creation order
3. **First applicable rule** : First matching rule determines the result
4. **Variant selection** : Uses deterministic hashing to choose variant

### Security

- Session authentication with `has_secure_password`
- CSRF protection enabled
- Input data validation
- Role-based authorization

## How It Works as an External Service

### Centralized Flag Management
- Single Rails instance manages all feature flags
- Multiple client applications call the API for flag evaluation
- Real-time evaluation on each API call

### Client Integration Example

```ruby
# In your e-commerce application
class DashboardController < ApplicationController
  def show
    flag_result = evaluate_feature_flag('new_dashboard', current_user)

    if flag_result['enabled'] && flag_result['variant'] == 'new'
      render 'dashboard/new_version'
    else
      render 'dashboard/old_version'
    end
  end

  private

  def evaluate_feature_flag(flag_name, user)
    response = HTTParty.post("http://your-feature-service.com/api/v1/evaluate/#{flag_name}", {
      body: {
        user_id: user.id,
        user_attributes: {
          id: user.id,
          email: user.email,
          role: user.role,
          country: user.country,
          subscription: user.subscription_type
        }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    })

    JSON.parse(response.body)
  end
end
```

### Evaluation Flow

1. **Client Request** : Your application sends user attributes to the API
2. **Rule Evaluation** : Service evaluates rules against user attributes
3. **Variant Selection** : Deterministic hashing selects variant for consistent experience
4. **Response** : Service returns flag status, variant, and evaluation context

### Benefits

- **Centralized Control** : Manage all feature flags from one place
- **Real-time Updates** : Changes take effect immediately across all applications
- **Consistent Experience** : Same user always gets same variant (deterministic)
- **A/B Testing** : Built-in support for multiple variants with weights
- **Kill Switch** : Instantly disable features across all applications

## Testing

```bash
# Run all tests
bundle exec rspec

# Tests with documentation format
bundle exec rspec --format documentation
```

## Production Environment

1. **Environment variables**
   ```bash
   export RAILS_ENV=production
   export SECRET_KEY_BASE=<your-secret-key>
   export DATABASE_URL=<your-database-url>
   ```

2. **Compile assets**
   ```bash
   rails assets:precompile
   ```

3. **Migrate database**
   ```bash
   rails db:migrate
   ```

## Deployment with Kamal

The project is configured for deployment with Kamal:

```bash
# Initial setup
kamal setup

# Deploy
kamal deploy
```

## API Authentication for Production

For production use, implement API key authentication:

1. Generate API keys for client applications
2. Add API key validation in `Api::V1::BaseController`
3. Include API key in client requests

Example implementation:
```ruby
# In Api::V1::BaseController
before_action :authenticate_api_key!

private

def authenticate_api_key!
  api_key = request.headers['X-API-Key']
  unless valid_api_key?(api_key)
    render json: { error: 'Invalid API key' }, status: :unauthorized
  end
end
```

## Contributing

1. Fork the project
2. Create a feature branch
3. Add tests for your code
4. Ensure all tests pass
5. Create a Pull Request

## License

MIT License - see LICENSE file for details.
