(() => {
  "use strict";

  const seiten = [
    { datei: "index.html", label: "Vault" },
    { datei: "artefakte.html", label: "Artefakte" },
    { datei: "doom-scroll-quiz.html", label: "Quiz" },
    { datei: "lernwelt.html", label: "Lernwelt" }
  ];
  const pfadDatei = location.pathname.split("/").pop() || "index.html";
  const aktuelleNummer = seiten.findIndex(seite => seite.datei === pfadDatei);
  const bewegungReduziert = matchMedia("(prefers-reduced-motion: reduce)");
  let wechselTimer = 0;

  function zielNummer(url) {
    try {
      const ziel = new URL(url, location.href);
      if (ziel.origin !== location.origin) return -1;
      return seiten.findIndex(seite => ziel.pathname.endsWith(`/${seite.datei}`));
    } catch {
      return -1;
    }
  }

  function navigationBeschriften() {
    document.querySelectorAll(".bottom-app-bar__navigation").forEach(navigation => {
      [...navigation.children].slice(0, seiten.length).forEach((eintrag, nummer) => {
        eintrag.classList.add("app-page-item");
        if (!eintrag.querySelector(".app-nav-label")) {
          const label = document.createElement("span");
          label.className = "app-nav-label";
          label.textContent = seiten[nummer].label;
          label.setAttribute("aria-hidden", "true");
          eintrag.append(label);
        }
      });
    });
  }

  function eintrittAnimieren() {
    if (bewegungReduziert.matches) return;
    const richtung = sessionStorage.getItem("thors-core.seitenrichtung");
    sessionStorage.removeItem("thors-core.seitenrichtung");
    if (richtung !== "links" && richtung !== "rechts") return;
    document.body.classList.add(
      "app-seite-eintritt",
      richtung === "links"
        ? "app-seite-eintritt--von-rechts"
        : "app-seite-eintritt--von-links"
    );
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        document.body.classList.add("app-seite-eintritt--aktiv");
      });
    });
    window.setTimeout(() => {
      document.body.classList.remove(
        "app-seite-eintritt",
        "app-seite-eintritt--von-rechts",
        "app-seite-eintritt--von-links",
        "app-seite-eintritt--aktiv"
      );
    }, 240);
  }

  function navigieren(url) {
    const nummer = zielNummer(url);
    if (nummer < 0 || aktuelleNummer < 0 || nummer === aktuelleNummer) {
      location.href = url;
      return;
    }
    const richtung = nummer > aktuelleNummer ? "links" : "rechts";
    sessionStorage.setItem("thors-core.seitenrichtung", richtung);
    window.clearTimeout(wechselTimer);
    if (bewegungReduziert.matches) {
      location.href = url;
      return;
    }
    document.body.classList.remove(
      "app-seite-austritt--links",
      "app-seite-austritt--rechts"
    );
    document.body.classList.add(
      "app-seite-austritt",
      `app-seite-austritt--${richtung}`
    );
    wechselTimer = window.setTimeout(() => {
      location.href = url;
    }, 190);
  }

  window.thorsCoreNavigieren = navigieren;
  document.addEventListener("click", event => {
    const link = event.target.closest("a[href]");
    if (!link || event.defaultPrevented || event.button !== 0) return;
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    if (link.target && link.target !== "_self") return;
    if (zielNummer(link.href) < 0) return;
    event.preventDefault();
    navigieren(link.href);
  });

  let wischen = null;
  window.addEventListener("pointerdown", event => {
    if (event.pointerType !== "touch" || aktuelleNummer < 0) return;
    const amRand = event.clientX <= 34 || event.clientX >= innerWidth - 34;
    const nichtVerfügbar =
      document.body.dataset.offenerDrawer ||
      event.target.closest("button, a, input, select, textarea, [role='dialog']");
    if (!amRand || nichtVerfügbar) return;
    wischen = {
      id: event.pointerId,
      x: event.clientX,
      y: event.clientY
    };
  }, { passive: true });

  window.addEventListener("pointerup", event => {
    if (!wischen || event.pointerId !== wischen.id) return;
    const deltaX = event.clientX - wischen.x;
    const deltaY = event.clientY - wischen.y;
    wischen = null;
    if (Math.abs(deltaX) < 70 || Math.abs(deltaY) > 45) return;
    const nächsteNummer = aktuelleNummer + (deltaX < 0 ? 1 : -1);
    if (nächsteNummer < 0 || nächsteNummer >= seiten.length) return;
    navigieren(seiten[nächsteNummer].datei);
  }, { passive: true });

  navigationBeschriften();
  eintrittAnimieren();
})();
