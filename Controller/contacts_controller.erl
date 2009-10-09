-module(contacts_controller, [Req]).
-compile(export_all).

%%%
% LIST Functions
%%%
list('GET', []) ->
    list('GET', ["1"]);

list('GET', [PageId]) ->
	list('GET', [PageId, "25"]);

list('GET', [PageIdList, PerPageList]) ->
	PageId = list_to_integer(PageIdList),
	PerPage = list_to_integer(PerPageList),
    {ok, [ {contacts, boss_db:find(contact, [], PerPage, PerPage * (PageId - 1))} ]}.



%%%
% CREATE Functions
%%%
create('GET', []) ->
	{ok, [
		{title, "Create"},
		{errors, []},
		{contact, contact:new(id, "", "", "")}
	]};
	
create('POST', []) ->
	Length = length(Req:get_post_value("name")),
	if 
		Length == 0 ->
			Return = {ok, [
				{title, "Create"},
				{errors, ["Name cannot be blank"]},
				{contact, contact:new(id, Req:get_post_value("name"), 
										Req:get_post_value("email"),
										Req:get_post_value("number"))}
			]};
		true ->
			Contact = contact:new(id, Req:get_post_value("name"), 
									Req:get_post_value("email"),
									Req:get_post_value("number")),
			ContactSaved = Contact:save(),
			Return = {redirect, "/contacts/view/" ++ ContactSaved:id()}
	end,
	Return.


%%%
% EDIT Functions
%%%
edit('GET', [Id]) ->
	Contact = boss_db:find(Id),
	{ok, [
		{title, "Edit " ++ Contact:name()},
		{contact, Contact}
	]};
	
edit('POST', [Id]) ->
	OriginalContact = boss_db:find(Id),
	Length = length(Req:get_post_value("name")),
	if 
		Length == 0 ->
			Return = {ok, [
				{title, "Edit " ++ OriginalContact:name()},
				{errors, ["Name cannot be blank"]},
				{contact, contact:new(id, OriginalContact:name(), 
										Req:get_post_value("email"),
										Req:get_post_value("number"))}
			]};
		true ->
			Contact = contact:new(OriginalContact:id(), Req:get_post_value("name"), 
									Req:get_post_value("email"),
									Req:get_post_value("number")),
			ContactSaved = Contact:save(),
			Return = {redirect, "/contacts/view/" ++ ContactSaved:id()}
	end,
	Return.
	
%%%
% VIEW Function
%%%	
view('GET', [Id]) ->
	Contact = boss_db:find(Id),
	{ok, [
		{title, "View " ++ Contact:name()},
		{contact, Contact}
	]}.
	
delete('GET', [Id]) ->
	boss_db:delete(Id),
	{redirect, "/contacts/list"}.