<?php

/*
 * (c) Paul Annekov <paul.annekov@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

class Main
{
    private $options = [
        'docks' => [
            0 => [
                // Expected value in hours.
                'e' => 10,
                // Variance in hours.
                'var' => 3,
                'cranes' => 2
            ],
            1 => [
                'e' => 15,
                'var' => 5,
                'cranes' => 2
            ],
            2 => [
                'e' => 20,
                'var' => 6,
                'cranes' => 2
            ]
        ],
        'ships' => [
            0 => [
                // The probability of occurrence.
                'p' => 0.2,
                'docks' => [0, 1, 2]
            ],
            1 => [
                'p' => 0.3,
                'docks' => [0, 1]
            ],
            2 => [
                'p' => 0.5,
                'docks' => [2]
            ]
        ],
        'interval' => [
            'e' => 2,
            'var' => 0.5,
        ],
        // Max analyze time in hours.
        'time_max' => 200,
        // Up to minutes.
        'accuracy' => 60,
        'normal_distribution_iterations' => 10
    ];

    /**
     * @var array Ships in queue.
     */
    private $shipsQueue = [];

    /**
     * @var array Ships that were already served.
     */
    private $shipsReady = [];

    /**
     * @var array Current docks states.
     */
    private $docksState = [];

    /**
     * @var int Current time.
     */
    private $currentTime = 0;

    /**
     * Generates a random variable from 0.0 to 1.0 also known as Xi.
     *
     * @return float Random variable.
     */
    private function generateXi()
    {
        return mt_rand() / mt_getrandmax();
    }

    /**
     * Generates a random number in accordance with the uniform distribution.
     *
     * @param int $e Expected value - E(X).
     * @param int $var Variance - Var(X).
     * @return float Random number.
     */
    private function uniformDistributionRand($e, $var)
    {
        $from = $e - $var * sqrt(3);
        $to = $e + $var * sqrt(3);

        return $from + ($to - $from) * $this->generateXi();
    }

    /**
     * Generates a random number in accordance with the normal distribution.
     *
     * @param int $e Expected value - E(X).
     * @param int $var Variance - Var(X).
     * @return float Random number.
     */
    private function normalDistributionRand($e, $var)
    {
        $total = 0;
        for ($i = 0; $i < $this->options['normal_distribution_iterations']; $i++) {
            $total += $this->uniformDistributionRand($e, $var);
        }

        return $total / $this->options['normal_distribution_iterations'];
    }

    /**
     * Gets random ship type.
     *
     * @return int Ship type.
     */
    private function generateShipType()
    {
        $xi = $this->generateXi();
        $intervalStart = 0;

        foreach ($this->options['ships'] as $id => $ship) {
            if ($xi > $intervalStart && $xi < $intervalStart + $ship['p']) {
                return $id;
            }

            $intervalStart += $ship['p'];
        }

        return false;
    }

    /**
     * Processes events on the dock at a current time.
     *
     * @param int $id Dock ID.
     */
    private function dockProcess($id)
    {
        $freeCranes = [];
        foreach ($this->docksState[$id]['cranes'] as $craneId => $ship) {
            if (!empty($ship) && $ship['completed'] <= $this->currentTime) {
                $this->shipsReady[] = $ship;
                $this->docksState[$id]['cranes'][$craneId] = [];
            }

            if (empty($this->docksState[$id]['cranes'][$craneId])) {
                $freeCranes[] = $craneId;
            }
        }

        if (empty($freeCranes)) {
            return;
        }

        foreach ($this->shipsQueue as $shipId => $ship) {
            if (!in_array($id, $this->options['ships'][$ship['type']]['docks'])) {
                continue;
            }

            $craneId = key($freeCranes);
            $ship['taken'] = $this->currentTime;
            $ship['completed'] = $this->currentTime + round(
                    $this->normalDistributionRand(
                        $this->options['docks'][$id]['e'],
                        $this->options['docks'][$id]['var']
                    )
                );
            $this->docksState[$id]['cranes'][$freeCranes[$craneId]] = $ship;
            unset($this->shipsQueue[$shipId]);
            unset($freeCranes[$craneId]);

            if (empty($freeCranes)) {
                return;
            }
        }
    }

    /**
     * Initiates modeling process.
     */
    private function init()
    {
        $this->currentTime = 0;

        foreach ($this->options['docks'] as $id => $dock) {
            $this->docksState[$id] = [
                'cranes' => []
            ];

            for ($i = 0; $i < $dock['cranes']; $i++) {
                $this->docksState[$id]['cranes'][$i] = [];
            }
        }

        array_walk(
            $this->options['docks'],
            function (&$dock) {
                $dock['e'] *= $this->options['accuracy'];
                $dock['var'] *= $this->options['accuracy'];
            }
        );
        $this->options['interval']['e'] *= $this->options['accuracy'];
        $this->options['interval']['var'] *= $this->options['accuracy'];

        uasort(
            $this->options['ships'],
            function ($a, $b) {
                if ($a['p'] == $b['p']) {
                    return 0;
                }

                return ($a['p'] < $b['p']) ? -1 : 1;
            }
        );
    }

    /**
     * Starts model.
     */
    function run()
    {
        $this->init();

        $time_max = $this->options['time_max'] * $this->options['accuracy'];

        $nextShipTime = 0;
        while ($this->currentTime < $time_max) {
            if ($nextShipTime && $this->currentTime == $nextShipTime) {
                $this->shipsQueue[] = [
                    'arrived' => $this->currentTime,
                    'type' => $this->generateShipType()
                ];
                $nextShipTime = 0;
            }

            if (!$nextShipTime) {
                $nextShipTime = $this->currentTime + round(
                        $this->uniformDistributionRand(
                            $this->options['interval']['e'],
                            $this->options['interval']['var']
                        )
                    );
            }

            for ($i = 0; $i < count($this->options['docks']); $i++) {
                $this->dockProcess($i);
            }

            $this->currentTime++;
        }

        $this->output();
    }

    /**
     * Outputs results to console.
     */
    private function output()
    {
        $shipsIdle = [];
        foreach ($this->shipsReady as $ship) {
            if (!isset($shipsIdle[$ship['type']])) {
                $shipsIdle[$ship['type']] = [
                    'total_time' => 0,
                    'total_ships' => 0
                ];
            }

            $shipsIdle[$ship['type']]['total_ships']++;
            $shipsIdle[$ship['type']]['total_time'] += $ship['taken'] - $ship['arrived'];
        }

        ksort($shipsIdle);

        foreach ($shipsIdle as $type => $data) {
            echo "Ships of the type " . $type . ":\n";
            echo "\tNumber - " . $data['total_ships'] . "\n";
            echo "\tTotal downtime - " . $data['total_time'] . "\n";
            echo "\tMean downtime - " . round($data['total_time'] / $data['total_ships']) . "\n\n";
        }
    }
}