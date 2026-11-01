-- Princess Sparkle Pong | UI, scores, welcome, pause and winner screens.

local Effects = require("effects")
local Screens = {}
local C = Effects.colors
local setColor = Effects.setColor
local fonts = {}
local WIDTH, HEIGHT = 800, 600
local WIN_SCORE = 5

function Screens.init(w, h, winScore)
    WIDTH, HEIGHT, WIN_SCORE = w, h, winScore
    fonts.score = love.graphics.newFont(42)
    fonts.title = love.graphics.newFont(42)
    fonts.heading = love.graphics.newFont(30)
    fonts.medium = love.graphics.newFont(20)
    fonts.small = love.graphics.newFont(15)
end

function Screens.drawPlayfield(player1, player2, ball, score1, score2)
    -- Center line.
    love.graphics.setColor(0.90, 0.76, 1.00, 0.35)
    for y = 0, HEIGHT, 30 do
        love.graphics.rectangle("fill", WIDTH / 2 - 3, y, 6, 15, 2, 2)
    end

    -- Pink left paddle with a gentle glow.
    love.graphics.setColor(1.00, 0.51, 0.77, 0.14)
    love.graphics.rectangle("fill", player1.x - 6, player1.y - 6,
                            player1.width + 12, player1.height + 12, 9, 9)
    setColor(C.pink)
    love.graphics.rectangle("fill", player1.x, player1.y,
                            player1.width, player1.height, 6, 6)

    -- Purple right paddle with a gentle glow.
    love.graphics.setColor(0.72, 0.54, 1.00, 0.14)
    love.graphics.rectangle("fill", player2.x - 6, player2.y - 6,
                            player2.width + 12, player2.height + 12, 9, 9)
    setColor(C.purple)
    love.graphics.rectangle("fill", player2.x, player2.y,
                            player2.width, player2.height, 6, 6)

    -- Glitter particles and the heart-shaped ball.
    Effects.drawParticles()
    Effects.drawHeart(ball.x - 4, ball.y - 4, ball.size + 8, C.pink, 0.18)
    Effects.drawHeart(ball.x, ball.y, ball.size, C.cream, 1)
    love.graphics.setColor(1, 1, 1, 0.70)
    love.graphics.circle("fill", ball.x + ball.size * 0.28,
                         ball.y + ball.size * 0.24, 2)

    -- Large pink/purple scores.
    love.graphics.setFont(fonts.small)
    setColor(C.pink)
    love.graphics.print("PINK", 286, 17)
    setColor(C.purple)
    love.graphics.print("PURPLE", 459, 17)
    love.graphics.setFont(fonts.score)
    setColor(C.pink)
    love.graphics.print(tostring(score1), 300, 39)
    setColor(C.purple)
    love.graphics.print(tostring(score2), 477, 39)

    love.graphics.setFont(fonts.small)
    setColor(C.lavender, 0.85)
    love.graphics.printf("W / S", 40, HEIGHT - 30, 90, "center")
    love.graphics.printf("UP / DOWN", WIDTH - 150, HEIGHT - 30, 130, "center")
    love.graphics.printf("First to " .. WIN_SCORE .. "  |  P = Pause",
                         230, HEIGHT - 30, 340, "center")
end

local function drawOverlayPanel(x, y, w, h)
    love.graphics.setColor(0.06, 0.03, 0.11, 0.82)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    setColor(C.panel, 0.98)
    love.graphics.rectangle("fill", x, y, w, h, 24, 24)
    setColor(C.lavender, 0.75)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 24, 24)
end

local function drawCrown(cx, y)
    setColor(C.pink)
    love.graphics.rectangle("fill", cx - 44, y + 5, 88, 23, 4, 4)
    love.graphics.polygon("fill", cx - 44, y + 9, cx - 44, y - 17, cx - 17, y + 9)
    love.graphics.polygon("fill", cx - 19, y + 9, cx, y - 30, cx + 19, y + 9)
    love.graphics.polygon("fill", cx + 17, y + 9, cx + 44, y - 17, cx + 44, y + 9)
    setColor(C.cream)
    love.graphics.circle("fill", cx, y + 16, 4)
    love.graphics.circle("fill", cx - 29, y + 16, 3)
    love.graphics.circle("fill", cx + 29, y + 16, 3)
end

local function drawWelcome()
    drawOverlayPanel(91, 104, 618, 392)
    setColor(C.lavender)
    Effects.drawStar(170, 172, 18)
    Effects.drawStar(630, 172, 18)
    Effects.drawHeart(377, 135, 46, C.pink, 1)

    love.graphics.setFont(fonts.title)
    setColor(C.cream)
    love.graphics.printf("PRINCESS", 100, 199, 600, "center")
    love.graphics.setFont(fonts.heading)
    setColor(C.pink)
    love.graphics.printf("SPARKLE PONG", 100, 253, 600, "center")

    love.graphics.setFont(fonts.small)
    setColor(C.lavender)
    love.graphics.printf("A magical pink vs. purple arcade match!", 100, 303, 600, "center")
    love.graphics.printf("PINK: W / S       PURPLE: UP / DOWN", 100, 332, 600, "center")
    love.graphics.printf("First to 5 wins the crown", 100, 358, 600, "center")

    setColor(C.pink)
    love.graphics.rectangle("fill", 248, 402, 304, 56, 18, 18)
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.21, 0.07, 0.24, 1)
    love.graphics.printf("PRESS SPACE TO START", 248, 418, 304, "center")
end

local function drawWinner(winner, score1, score2)
    drawOverlayPanel(110, 132, 580, 346)
    drawCrown(WIDTH / 2, 208)
    love.graphics.setFont(fonts.heading)
    setColor(winner == 1 and C.pink or C.purple)
    love.graphics.printf(winner == 1 and "PINK PLAYER WINS!" or "PURPLE PLAYER WINS!",
                         120, 254, 560, "center")
    love.graphics.setFont(fonts.medium)
    setColor(C.cream)
    love.graphics.printf("Congratulations, sparkle champion!", 120, 310, 560, "center")
    love.graphics.setFont(fonts.small)
    setColor(C.lavender)
    love.graphics.printf("Final score: " .. score1 .. " - " .. score2,
                         120, 346, 560, "center")
    setColor(C.pink)
    love.graphics.rectangle("fill", 245, 391, 310, 52, 17, 17)
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.21, 0.07, 0.24, 1)
    love.graphics.printf("SPACE = PLAY AGAIN", 245, 404, 310, "center")
end

function Screens.drawOverlay(state, winner, score1, score2)
    if state == "welcome" then
        drawWelcome()
    elseif state == "winner" then
        drawWinner(winner, score1, score2)
    elseif state == "paused" then
        drawOverlayPanel(180, 205, 440, 185)
        love.graphics.setFont(fonts.heading)
        setColor(C.cream)
        love.graphics.printf("PAUSED", 180, 243, 440, "center")
        love.graphics.setFont(fonts.small)
        setColor(C.lavender)
        love.graphics.printf("Press P or SPACE to continue", 180, 314, 440, "center")
    end
end

return Screens
