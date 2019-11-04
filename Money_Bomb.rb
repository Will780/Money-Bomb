require 'gosu'

class Start < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Start"
        @background_image = Gosu::Image.new("media/city.jpg", :tileable => true)
        @font = Gosu::Font.new(24)
    end

    def update
        if Gosu.button_down? Gosu::KB_SPACE
            Tutorial.new.show
        end
        if Gosu.button_down? Gosu::KB_TAB
            close
        else
            super
        end
    end

    def draw
        @background_image.draw(0, 0, 0)
        @font.draw("Press Space to start \nPress Tab to quit \nPress Esc to go back to start", 10, 10, ZOrder::UI, 2.0, 2.0, Gosu::Color::BLACK)
    end
end

class Tutorial < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Money Bomb"

        @background_image = Gosu::Image.new("media/city.jpg", :tileable => true)

        @player = Player.new
        @player.warp(320, 432)

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
        @player.avoid_bombs(@bombs)

        if rand(150) < 2
            @coins.push(Coin.new)
        end
        if rand(150) < 1
            @bombs.push(Bomb.new)
        end
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            Start.new.show
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
        @x += 4
        @x %= 640
    end

    def move_left
        @x += -4
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
                @score += coin.value
            end
        end
    end

    def avoid_bombs(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 20
                Start.new.show
            end
        end
    end
end

class Coin
    attr_reader :x, :y, :value

    def initialize
        @image = Gosu::Image.new("media/coin.jpg")
        @x= rand * 640
        @y = 35
        if rand(40) < 3
            @value = 10
        else
            @value = 5
        end
    end

    def draw
        @image.draw(@x, @y, 1)
        @y += (@value / 2)
    end
end

class Bomb
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("media/bomb.png")
        @x= rand * 640
        @y = 35
    end

    def draw
        @image.draw(@x, @y, 1)
        @y += 3
    end
end

module ZOrder
    BACKGROUND, COINS, BOMBS, PLAYER, UI = *0..4
end

Start.new.show