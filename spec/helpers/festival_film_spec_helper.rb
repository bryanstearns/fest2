module FestivalFilmSpecHelper
  def make_festival_and_film
    @festival = mock_model(Festival, :public => true, :to_param => "1")
    @film = mock_model(Film, :to_param => "1")
    @films = [@film]
    @films.stub!(:find).and_return(@film)
    Festival.stub!(:find_by_slug!).and_return(@festival)
    @festival.stub!(:films).and_return(@films)
  end
end
