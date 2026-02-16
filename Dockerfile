FROM ruby:3.3

# Install system dependencies including libyaml for psych gem
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    libyaml-dev \
    build-essential \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /upload

# Copy Gemfile first for better caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Expose port
EXPOSE 3000

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0"]