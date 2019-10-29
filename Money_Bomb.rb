require 'gosu'

# class Start
#     super 640, 480
#     self.caption = "Money Bomb"
#     @background_image = Gosu::Image.new("media/someting.something")
# end

class Tutorial < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Money Bomb"

        @background_image = Gosu::Image.new("media/city.jpg", :tileable => true)

        @player = Player.new
        @player.warp(320, 435)

        @coins = Array.new

        @bombs = Array.new

        @font = Gosu::Font.new(25)
    end

    def update
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.move_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.move_right
        end
        # @coin.move
        # @bomb.move  why no method?
        @player.collect_coins(@coins)
        @player.avoid_bombs(@bombs)

        if rand(100) < 3
            @coins.push(Coin.new(@star_anim))
        end
        if rand(100) < 3
            @bombs.push(Bomb.new(@Bomb_anim))
        end
    end

    def draw
        @background_image.draw(0, 0, ZOrder::BACKGROUND)
        @player.draw
        @coins.each { |coin| coin.draw }
        @bombs.each { |bomb| bomb.draw }
        @font.draw("Money: $#{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end
end

class Player
    attr_reader :score

    def initialize
        @image = Gosu::Image.new("media/character.png")
        @score = 0
    end

    def warp(x, y)
        @x, @y = x, y
    end

    def move_right
        @x += 5
        @x %= 640
    end

    def move_left
        @x += -5
        @x %= 640
    end

    def draw
        @image.draw(@x, @y, 1)
    end

    def score
        @score
    end

    def collect_coins(coins)
        coins.reject! do |coin|
            if Gosu.distance(@x, @y, coin.x, coin.y) < 20
                @score += 2
            end
        end
    end

    def avoid_bombs(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 20
                close
            end
        end
    end
end

class Coin
    attr_reader :x, :y

    def initialize(animation)
        @image = Gosu::Image.new("media/coin.jpg")
        @x= rand * 640
        @y = 35
    end

    def draw
        @image.draw(@x, @y, 1)
    end

    def move
        @y += 4
        if @y > 468
            @coins.slice!(0)
        end
    end
end

class Bomb
    attr_reader :x, :y

    def initialize(animation)
        @image = Gosu::Image.new("media/bomb.png")
        @x= rand * 640
        @y = 35
    end

    def draw
        @image.draw(@x, @y, 1)
    end

    def move
        @y += 4
        if @y > 468
            @bombs.slice!(0)
        end
    end
end

module ZOrder
    BACKGROUND, COINS, BOMBS, PLAYER, UI = *0..4
end

Tutorial.new.show