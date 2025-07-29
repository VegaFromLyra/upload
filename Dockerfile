FROM ruby:3.2

# Install system dependencies including libyaml for psych gem
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    libyaml-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /myapp

# Copy Gemfile first for better caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Expose port
EXPOSE 3000

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0"]