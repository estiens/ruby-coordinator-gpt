FROM ruby:latest
WORKDIR /app
COPY . .
RUN bundle install
CMD ["ruby", "app/runner.rb"]