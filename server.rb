require 'sinatra'
require 'sinatra/flash'
require 'pry'
require 'csv'

enable :sessions

def article_info
    CSV.readlines('articles.csv')[1..-1].map do |article|
    { title: article[0], url: article[1], description: article[2] }
  end
end

def url_valid?(url)
  url.match(/^w{3}\..+\..{2,}/) ? true : false
end

def description_valid?(description)
  description.size >= 20
end

get '/articles/' do
  @articles = article_info
  erb :articles_index
end

get '/articles/:article_title' do
  @selected_article = article_info
    .select { |article| article[:title] == params[:article_title] }.first
  erb :articles_show
end

get '/new' do
  erb :articles_new
end

post '/articles' do
  if params[:title].empty?
    flash[:title_error] = "You must provid a title"
  end
  unless url_valid?(params[:url])
    flash.next[:url_error] = "You must provide a valid URL."
  end
  unless description_valid?(params[:description])
    flash.next[:description_error] = "Description must be 20 or more characters long"
  end
  unless flash.next[:description_error] || flash.next[:url_error]
    CSV.open('articles.csv', 'a') do |csv|
      csv << [ params[:title], params[:url], params[:description] ]
    end
    redirect '/articles/'
  else
    redirect '/new'
  end
end
