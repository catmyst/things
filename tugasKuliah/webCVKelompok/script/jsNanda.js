let profile = document.getElementById('anandaProfile');

function spin()
{
    profile.src="../assets/profileNanda.jpg"
    let rng = Math.floor(Math.random() * 10)
    if(rng == 0) profile.src="../assets/cyrene.jpg"
    else if (rng == 1) window.location = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    profile.classList.remove('spin');
    profile.offsetWidth;
    profile.classList.add('spin');
}

toString