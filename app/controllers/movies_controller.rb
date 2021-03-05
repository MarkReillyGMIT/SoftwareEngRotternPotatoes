class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @ratings_to_show = params[:ratings]
  
    #Sorting and filtering
    sort = params[:sort] or session[:sort]
   
    case sort
    when 'title'
      ordering, @title_header = {:title => :asc}, "hilite"
    when 'release_date'
      ordering, @release_date_header = {:release_date => :asc}, "hilite"
    end
    
   #Check boxes 
    if params[:ratings]
      if params[:ratings].kind_of?(Hash)
        @ratings_to_show =params[:ratings].keys
      else
        @ratings_to_show = params[:ratings]
      end
    elsif session[:ratings]
      @ratings_to_show = session[:ratings]
    else
      @ratings_to_show = @all_ratings
    end
    #If there is no sort or ratings, set the session of those.
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort], session[:ratings] = sort, @ratings_to_show
      redirect_to movies_path sort: sort, ratings: @ratings_to_show
    end
    
    @movies = Movie.with_ratings(@ratings_to_show).order(sort)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
