ChatEmoteDB = ChatEmoteDB or {}
defaults = {
  [":)"] = "SMILE", -- "SMILE"
  [":("] = "CRY", -- "CRY"
}
local disabled = false
local EmoValidate = {}
local CopyTable
CopyTable = function(t,copied)
  copied = copied or {}
  local copy = {}
  copied[t] = copy
  for k,v in pairs(t) do
    if type(v) == "table" then
      if copied[v] then
        copy[k] = copied[v]
      else
        copy[k] = CopyTable(v,copied)
      end
    else
      copy[k] = v
    end
  end
  return copy
end
local t_count = function(t)
  local count = 0
  for k,v in pairs(t) do
    count = count+1
  end
  return count
end
local Print = function(msg)
  if not DEFAULT_CHAT_FRAME:IsVisible() then
    FCF_SelectDockFrame(DEFAULT_CHAT_FRAME)
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cff660066ChatEmote: |r"..msg)
end
local events = CreateFrame("Frame")
events:SetScript("OnEvent",function() 
  if events[event] ~= nil then return events[event](this,event,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11) end
end)
events:RegisterEvent("VARIABLES_LOADED")
local orig_SendChatMessage = SendChatMessage
local function ChatEmoteSendChatMessage(msg, system, language, channel)
  local emote = ChatEmoteDB[msg]
  if emote ~= nil then -- only exact match so we don't filter "hi :)"
    return DoEmote(emote,nil)
  end
  orig_SendChatMessage(msg, system, language, channel)
end

local help = function()
  Print("/chatemote list")
  Print("    lists all emote tokens")
  Print("/chatemote link emoticon EMOTE")
  Print("    example: /chatemote link o_O CONFUSED")
  Print("/chatemote unlink EMOTE")
  Print("    removes the link to EMOTE")
  Print("/chatemote toggle")
  Print("    enable or disable the addon")
end

local toggle = function()
  if disabled then
    SendChatMessage = ChatEmoteSendChatMessage
    disabled = false
    Print("Enabled.")
  else
    SendChatMessage = orig_SendChatMessage
    disabled = true
    Print("Disabled.")
    Print("    Use /chatemote toggle again to re-enable")
  end
end

local reverse = function(a,b)
  return a > b
end
local count, tempT = 0,{}
SlashCmdList["CHATEMOTE"] = function(msg)
  if msg == nil or msg == "" then
    help()
  else
    local args = {}
    for arg in string.gfind(msg,"%S+") do
      table.insert(args,arg)
    end
    local argn = table.getn(args)
    if argn > 0 then
      local cmd = args[1]
      if cmd == "list" then
        if not next(tempT) then
          for e in pairs(EmoValidate) do
            table.insert(tempT,e)
          end
          table.sort(tempT,reverse)           
        end
        for i,e in ipairs(tempT) do
          count = count + 1
          Print(table.remove(tempT))
          if count > 10 then
            Print("    /chatemote list for more")
            count = 0
            return
          end
        end
        count, tempT = 0, {}
        Print("    emote list complete")       
      elseif cmd == "link" then
        if argn < 3 then
          Print("/chatemote link emoticon EMOTE")
          Print("    example: /chatemote link o_O CONFUSED")
        else 
          if not EmoValidate[args[3]] then
            Print(""..args[3].." is not a valid Emote")
          else
            ChatEmoteDB[args[2]] = args[3]
          end
        end
      elseif cmd == "unlink" then
        if argn < 2 then
          Print("/chatemote unlink EMOTE")
          Print("    removes the link to EMOTE")          
        else
          for k,v in pairs(ChatEmoteDB) do
            if args[2] == v then
              ChatEmoteDB[k] = nil
            end
          end
        end
      elseif cmd == "toggle" then
        toggle()
      end
    else
      help()
    end
  end
end
events.VARIABLES_LOADED = function(self,event)
  if not next(ChatEmoteDB) then
    ChatEmoteDB = CopyTable(defaults)
  end
  SendChatMessage = ChatEmoteSendChatMessage
  local i = 1
  while getglobal("EMOTE"..i.."_TOKEN") ~= nil do
    EmoValidate[getglobal("EMOTE"..i.."_TOKEN")]=true
    i = i+1
  end
end
SlashCmdList["CEMO"] = SlashCmdList["CHATEMOTE"]
SLASH_CEMO1 = "/cemo"
SLASH_CHATEMOTE1 = "/chatemote"