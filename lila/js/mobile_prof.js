var menu = $(".menu-bar"),
	toggle_menu = false;

document.getElementById("menu").addEventListener("click", menu_expand);

function menu_expand() {
	if (toggle_menu) {
		toggle_menu = false;
		menu.removeClass("expanded");
	}
	else {
		toggle_menu = true;
		menu.addClass("expanded");
	}
}
