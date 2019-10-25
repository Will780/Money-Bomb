require 'gosu'

class Blackhole
    attr_reader :x, :y

    def initialize(animation)
        @image = Gosu::Image.new("media/blackhole.png")
        @x = rand * 720
        @y = rand * 560
    end

    def draw
        @image.draw(@x, @y, 1)
    end
end

class Star
    attr_reader :x, :y

    def initialize(animation)
        @animation = animation
        @color = Gosu::Color::BLACK.dup
        @color.red = rand(256 - 40) + 40
        @color.green = rand(256 - 40) + 40
        @color.blue = rand(256 - 40) + 40
        @x = rand * 720
        @y = rand * 560
    end

    def draw
        img = @animation[Gosu.milliseconds / 100 % @animation.size]
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
            ZOrder::STARS, 1, 1, @color, :add)
    end
end

class Player
    attr_reader :score

    def initialize
        @image = Gosu::Image.new("media/starfighter.bmp")
        @beep = Gosu::Sample.new("media/beep.wav")
        @x = @y = @vel_x = @vel_y = @angle = 0.0
        @score = 0
    end

    def warp(x, y)
        @x, @y = x, y
    end

    def turn_left
        @angle -= 6.0
    end

    def turn_right
        @angle += 6.0
    end

    def accelerate
        @vel_x += Gosu.offset_x(@angle, 0.6)
        @vel_y += Gosu.offset_y(@angle, 0.6)
    end

    def move
        @x += @vel_x
        @y += @vel_y
        @x %= 720
        @y %= 560

        @vel_x *= 0.97
        @vel_y *= 0.97
    end

    def draw
        @image.draw_rot(@x, @y, 1, @angle)
    end

    def score
        @score
    end

    def collect_stars(stars)
        stars.reject! do |star| 
            if Gosu.distance(@x, @y, star.x, star.y) < 35
                @score += 10
                @beep.play
                true
            else
                false
            end
        end
    end

    def avoid_blackholes(blackholes)
        blackholes.reject! do |blackhole| 
            if Gosu.distance(@x, @y, blackhole.x, blackhole.y) < 28
                @score = 0
            end
        end
    end
end

module ZOrder
    BACKGROUND, STARS, BLACKHOLES, PLAYER, UI = *0..4
end

class Tutorial < Gosu::Window
    def initialize
        super 720, 560
        self.caption = "Tutorial Game"

        @background_image = Gosu::Image.new("media/space.png", :tileable => true)

        @player = Player.new
        @player.warp(360, 280)

        @star_anim = Gosu::Image.load_tiles("media/star.png", 25, 25)
        @stars = Array.new

        @blackholes = Array.new

        @font = Gosu::Font.new(25)
    end

    def update
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.turn_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.turn_right
        end
        if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
            @player.accelerate
        end
        if Gosu.button_down? Gosu::KB_SPACE
            @player.warp(rand * 720, rand * 560)
        end
        @player.move
        @player.collect_stars(@stars)
        @player.avoid_blackholes(@blackholes)

        if rand(100) < 4 and @stars.size < 25
            @stars.push(Star.new(@star_anim))
        end

        if rand(100) < 4 and @blackholes.size < 10
            @blackholes.push(Blackhole.new(@blackhole_anim))
        end

        if @blackholes.size == 10
            @blackholes.slice!(0)
        end
    end

    def draw
        @background_image.draw(0, 0, ZOrder::BACKGROUND)
        @player.draw
        @stars.each { |star| star.draw }
        @blackholes.each { |blackhole| blackhole.draw }
        @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end

Tutorial.new.show