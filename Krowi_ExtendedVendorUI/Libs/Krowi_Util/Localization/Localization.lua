--[[
    Copyright (c) 2023 Krowi

    All Rights Reserved unless otherwise explicitly stated.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

local lib = LibStub("Krowi_Util-1.0");

if not lib then
	return;
end

lib.L = LibStub("AceLocale-3.0"):GetLocale("Krowi_Util-1.0");

lib.L["Requires a reload"] = lib.L["Requires a reload"]:SetColorOrange();