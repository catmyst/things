let CVananda = document.getElementById("ananda");
let CVilham = document.getElementById("ilham");
let CVnabila = document.getElementById("nabila");
let CVsyauqi = document.getElementById("syauqi");
let index = 0;

let isDark = false;
function toggleDark(){
    document.getElementById("ilham").classList.toggle("dark");
}

function change(val)
{
    transition();
    setTimeout(function(){
    index += val;
    if (index < 0) index = 3;
    else if (index > 3) index = 0;
    switch (index)
    {
        case 0:
            CVananda.classList.add('display');
            CVilham.classList.remove('display');
            CVnabila.classList.remove('display');
            CVsyauqi.classList.remove('display');
        break;
        case 1:
            CVananda.classList.remove('display');
            CVilham.classList.add('display');
            CVnabila.classList.remove('display');
            CVsyauqi.classList.remove('display');
        break;
        case 2:
            CVananda.classList.remove('display');
            CVilham.classList.remove('display');
            CVnabila.classList.add('display');
            CVsyauqi.classList.remove('display');
        break;
        case 3:
            CVananda.classList.remove('display');
            CVilham.classList.remove('display');
            CVnabila.classList.remove('display');
            CVsyauqi.classList.add('display');
        break;
    }
    }, 1000);
}
function transition()
{
    let screen = document.getElementById("transition");
    screen.classList.add("trans");
    screen.offsetWidth;
    setTimeout(function(){
        screen.classList.remove('trans');
    },  1900);
} 