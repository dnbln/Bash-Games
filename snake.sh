#!/usr/bin/bash

tput civis

function end() {
	printf "\n\nFinal score: %d\n" $score
	tput cnorm
	exit 0
}

function build_grid() {
	GRID=()
	for ((i = 0; i < 22; i++)); do
		for ((j = 0; j < 22; j++)); do
			if [ $i -eq 0 ] || [ $j -eq 0 ] || [ $i -eq 21 ] || [ $j -eq 21 ]; then
				GRID+=('#')
			else
				GRID+=(' ')
			fi
		done
	done
	export GRID=$GRID
}

function game() {
	playing=1

	SNAKE=(10 10)
	up=1
	down=0
	left=0
	right=0
	frame=0
	score=0
	export score=$score
	GRID_BUF=""
	apple_x=$((RANDOM % 20 + 1))
	apple_y=$((RANDOM % 20 + 1))
	index_apple=$((apple_y * 22 + apple_x))

	while [[ $playing -eq 1 ]]; do
		while read -s -n 1 -t 0.0001 key; do
			if [[ $key == "w" ]]; then
				up=1
				down=0
				left=0
				right=0
			fi
			if [[ $key == "s" ]]; then
				up=0
				down=1
				left=0
				right=0
			fi
			if [[ $key == "a" ]]; then
				up=0
				down=0
				left=1
				right=0
			fi
			if [[ $key == "d" ]]; then
				up=0
				down=0
				left=0
				right=1
			fi
		done
		if [[ $frame -eq 0 ]]; then
			for ((i = ${#SNAKE[@]} - 1; i >= 2; i--)); do
				SNAKE[$i]=${SNAKE[$i-2]}
			done
			if [[ $up -eq 1 ]]; then
				SNAKE[1]=$((${SNAKE[1]} - 1))
				if [[ ${SNAKE[1]} -eq 0 ]]; then
					playing=0
					break
				fi
			fi
			if [[ $down -eq 1 ]]; then
				SNAKE[1]=$((${SNAKE[1]} + 1))
				if [[ ${SNAKE[1]} -eq 21 ]]; then
					playing=0
					break
				fi
			fi
			if [[ $left -eq 1 ]]; then
				SNAKE[0]=$((${SNAKE[0]} - 1))
				if [[ ${SNAKE[0]} -eq 0 ]]
				then
					playing=0
					break
				fi
			fi
			if [[ $right -eq 1 ]]; then
				SNAKE[0]=$((${SNAKE[0]} + 1))
				if [[ ${SNAKE[0]} -eq 21 ]]
				then
					playing=0
					break
				fi
			fi
			build_grid

			x=${SNAKE[0]}
			y=${SNAKE[1]}
			index_head=$((y * 22 + x))
			GRID[$index_head]='H'

			for ((i = 1; i < ${#SNAKE[@]}/2; i++)); do
				v=$((i * 2))
				x=${SNAKE[$v]}
				y=${SNAKE[$v+1]}
				index=$((y * 22 + x))
				GRID[$index]='T'
				if [[ $index_head -eq $index ]]; then
					GRID[$index]='B'
					playing=0
					break
				fi
			done

			if [[ $index_apple -eq $index_head ]]; then
				score=$((score + 1))
				export score=$score
				SNAKE+=(0, 0)

				while [ ${GRID[$index_apple]} == 'H' ] || [ ${GRID[$index_apple]} == 'T' ]; do
					apple_x=$((RANDOM % 20 + 1))
					apple_y=$((RANDOM % 20 + 1))
					index_apple=$((apple_y * 22 + apple_x))
				done
			fi
			GRID[$index_apple]='A'

			GRID_BUF=""
			for ((i = 0; i < 22; i++)); do
				for ((j = 0; j < 22; j++)); do
					index=$((i * 22 + j))
					val=${GRID[$index]}
					if [[ $val != ' ' ]]; then
						GRID_BUF+=${GRID[$index]}
					else
						GRID_BUF+=" "
					fi
				done
				GRID_BUF+="\n"
			done
		fi

		clear
		printf "$GRID_BUF"
		printf "\n\nScore: %d\n" $score
		sleep 0.1
		frame=$((frame + 1))
		frame=$((frame % 10))
	done
	end
}

trap "end" SIGHUP SIGINT SIGTERM
game
