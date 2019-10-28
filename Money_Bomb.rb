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

        @background_image = Gosu::Image.new("media/something.something", :tileable => true)

        @player = Player.new
        @player.warp(320, 30)

        @coin_anim = Gosu::Image.load_tiles("media/something.something", 25, 25)
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
        @player.collect_coins(@coins)

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
        @font.draw("Money: $#{@player.score}", 10, 10, Zorder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end
end

class Player
    attr_reader :score

    def initialize
        @image = Gosu::Image.new("media/something.something")
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
        @image.draw_rot(@x)
    end

    def score
        @score
    end

    def collect_coins(coins)
        coins.reject! do |coin|
            if Gosu.distance(@x, @y, coin.x, star.y) < 20
                @score += #variable
            end
        end
    end
end

class Coin
    attr_reader :x, :y

    def initialize(animation)
        @image = Gosu::Image.new("media/something.something")
        @x= rand * 640
        @y = 450
    end

    def draw
        @image.draw(@x, @y, 1)
    end
end

class Bomb
    attr_reader :x, :y

    def initialize(animation)
        @image = Gosu::Image.new("media/something.something")
        @x= rand * 640
        @y = 450
    end

    def draw
        @image.draw(@x, @y, 1)
    end
end

module ZOrder
    BACKGROUND, COINS, PLAYER, UI = *0..3
end

Tutorial.new.show